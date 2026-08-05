<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ListingResource;
use App\Models\Listing;
use App\Models\ListingImage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ListingController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $filters = $request->validate([
            'search' => ['nullable', 'string', 'max:180'],
            'category_id' => ['nullable', 'integer', 'exists:categories,id'],
            'district' => ['nullable', 'string', 'max:100'],
            'min_price' => ['nullable', 'numeric', 'gte:0'],
            'max_price' => ['nullable', 'numeric', 'gte:0'],
            'negotiable' => ['nullable', 'boolean'],
            'sort' => [
                'nullable',
                Rule::in(['newest', 'oldest', 'price_low', 'price_high']),
            ],
        ]);

        $query = Listing::query()
            ->with(['category', 'seller', 'images'])
            ->visible()
            ->when(
                filled($filters['search'] ?? null),
                function ($query) use ($filters): void {
                    $search = mb_strtolower(trim($filters['search']));
                    $pattern = "%{$search}%";

                    $query->where(function ($nested) use ($pattern): void {
                        $nested
                            ->whereRaw('LOWER(title) LIKE ?', [$pattern])
                            ->orWhereRaw(
                                'LOWER(COALESCE(description, \'\')) LIKE ?',
                                [$pattern]
                            );
                    });
                }
            )
            ->when(
                isset($filters['category_id']),
                fn ($query) => $query->where(
                    'category_id',
                    $filters['category_id']
                )
            )
            ->when(
                filled($filters['district'] ?? null),
                fn ($query) => $query->where(
                    'district',
                    $filters['district']
                )
            )
            ->when(
                isset($filters['min_price']),
                fn ($query) => $query->where(
                    'price',
                    '>=',
                    $filters['min_price']
                )
            )
            ->when(
                isset($filters['max_price']),
                fn ($query) => $query->where(
                    'price',
                    '<=',
                    $filters['max_price']
                )
            )
            ->when(
                array_key_exists('negotiable', $filters),
                fn ($query) => $query->where(
                    'is_negotiable',
                    $filters['negotiable']
                )
            );

        match ($filters['sort'] ?? 'newest') {
            'oldest' => $query->oldest(),
            'price_low' => $query->orderBy('price'),
            'price_high' => $query->orderByDesc('price'),
            default => $query->latest(),
        };

        return ListingResource::collection(
            $query->paginate(20)->withQueryString()
        );
    }

    public function show(Listing $listing): ListingResource
    {
        abort_unless($listing->status === 'active', 404);

        return new ListingResource(
            $listing->load(['category', 'seller', 'images'])
        );
    }

    public function store(Request $request): ListingResource
    {
        $data = $this->validated($request);
        $data['user_id'] = $request->user()->id;
        $data['status'] = 'active';

        $legacyImage = $request->file('image');
        unset($data['image'], $data['images']);

        $listing = DB::transaction(function () use (
            $request,
            $data,
            $legacyImage
        ): Listing {
            $listing = Listing::create($data);

            $files = $request->file('images', []);
            if ($legacyImage) {
                array_unshift($files, $legacyImage);
            }

            $this->storeImages($listing, $files);

            return $listing;
        });

        return new ListingResource(
            $listing->load(['category', 'seller', 'images'])
        );
    }

    public function update(Request $request, Listing $listing): ListingResource
    {
        $this->authorizeOwner($request, $listing);

        $data = $this->validated($request, true);

        $legacyImage = $request->file('image');
        unset($data['image'], $data['images']);

        DB::transaction(function () use (
            $request,
            $listing,
            $data,
            $legacyImage
        ): void {
            $listing->update($data);

            $files = $request->file('images', []);
            if ($legacyImage) {
                array_unshift($files, $legacyImage);
            }

            $this->storeImages($listing, $files);
        });

        return new ListingResource(
            $listing->fresh()->load(['category', 'seller', 'images'])
        );
    }

    public function updateStatus(
        Request $request,
        Listing $listing
    ): ListingResource {
        $this->authorizeOwner($request, $listing);

        $data = $request->validate([
            'status' => [
                'required',
                Rule::in(['active', 'paused', 'sold']),
            ],
        ]);

        $listing->update(['status' => $data['status']]);

        return new ListingResource(
            $listing->fresh()->load(['category', 'seller', 'images'])
        );
    }

    public function contact(Request $request, Listing $listing): JsonResponse
    {
        abort_unless($listing->status === 'active', 404);
        abort_if(
            $listing->user_id === $request->user()->id,
            422,
            'This is your own listing.'
        );

        $listing->loadMissing('seller:id,name,email,phone,district');

        return response()->json([
            'data' => [
                'seller_id' => $listing->seller->id,
                'name' => $listing->seller->name,
                'phone' => $listing->seller->phone,
                'email' => $listing->seller->email,
                'district' => $listing->seller->district,
            ],
        ]);
    }

    public function deleteImage(
        Request $request,
        Listing $listing,
        ListingImage $image
    ): Response {
        $this->authorizeOwner($request, $listing);
        abort_unless($image->listing_id === $listing->id, 404);

        DB::transaction(function () use ($listing, $image): void {
            Storage::disk('public')->delete($image->path);
            $image->delete();
            $this->normalizeImageOrder($listing);
        });

        return response()->noContent();
    }

    public function setCoverImage(
        Request $request,
        Listing $listing,
        ListingImage $image
    ): ListingResource {
        $this->authorizeOwner($request, $listing);
        abort_unless($image->listing_id === $listing->id, 404);

        DB::transaction(function () use ($listing, $image): void {
            $ordered = $listing->images()
                ->orderBy('sort_order')
                ->orderBy('id')
                ->get();

            $position = 1;
            foreach ($ordered as $item) {
                $item->update([
                    'sort_order' => $item->is($image) ? 0 : $position++,
                ]);
            }
        });

        return new ListingResource(
            $listing->fresh()->load(['category', 'seller', 'images'])
        );
    }

    public function destroy(Request $request, Listing $listing): Response
    {
        $this->authorizeOwner($request, $listing);

        $listing->loadMissing('images');

        Storage::disk('public')->delete(
            $listing->images->pluck('path')->all()
        );

        if ($listing->image_path) {
            Storage::disk('public')->delete($listing->image_path);
        }

        $listing->delete();

        return response()->noContent();
    }

    public function mine(Request $request): AnonymousResourceCollection
    {
        $filters = $request->validate([
            'status' => [
                'nullable',
                Rule::in(['active', 'paused', 'sold']),
            ],
        ]);

        return ListingResource::collection(
            Listing::query()
                ->with(['category', 'seller', 'images'])
                ->where('user_id', $request->user()->id)
                ->when(
                    isset($filters['status']),
                    fn ($query) => $query->where(
                        'status',
                        $filters['status']
                    )
                )
                ->latest()
                ->paginate(20)
        );
    }

    public function markSold(
        Request $request,
        Listing $listing
    ): ListingResource {
        $request->merge(['status' => 'sold']);

        return $this->updateStatus($request, $listing);
    }

    private function storeImages(Listing $listing, array $files): void
    {
        if ($files === []) {
            return;
        }

        $existingCount = $listing->images()->count();
        abort_if(
            $existingCount + count($files) > 5,
            422,
            'A listing can contain at most 5 images.'
        );

        foreach ($files as $offset => $file) {
            $listing->images()->create([
                'path' => $file->store('listings', 'public'),
                'sort_order' => $existingCount + $offset,
            ]);
        }
    }

    private function normalizeImageOrder(Listing $listing): void
    {
        $listing->images()
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get()
            ->each(
                fn (ListingImage $image, int $index) => $image->update([
                    'sort_order' => $index,
                ])
            );
    }

    private function authorizeOwner(
        Request $request,
        Listing $listing
    ): void {
        abort_unless(
            $listing->user_id === $request->user()->id,
            403
        );
    }

    private function validated(Request $request, bool $updating = false): array
    {
        return $request->validate([
            'category_id' => [
                $updating ? 'sometimes' : 'required',
                'integer',
                Rule::exists('categories', 'id')->where('is_active', true),
            ],
            'title' => [
                $updating ? 'sometimes' : 'required',
                'string',
                'max:180',
            ],
            'description' => ['nullable', 'string', 'max:5000'],
            'quantity' => [
                $updating ? 'sometimes' : 'required',
                'numeric',
                'gt:0',
            ],
            'unit' => [
                $updating ? 'sometimes' : 'required',
                'string',
                'max:40',
            ],
            'price' => [
                $updating ? 'sometimes' : 'required',
                'numeric',
                'gte:0',
            ],
            'is_negotiable' => ['sometimes', 'boolean'],
            'district' => [
                $updating ? 'sometimes' : 'required',
                'string',
                'max:100',
            ],
            'location' => ['nullable', 'string', 'max:180'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'available_date' => ['nullable', 'date'],
            'image' => ['nullable', 'image', 'max:5120'],
            'images' => ['nullable', 'array', 'max:5'],
            'images.*' => ['image', 'max:5120'],
        ]);
    }
}
