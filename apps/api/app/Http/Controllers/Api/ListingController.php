<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ListingResource;
use App\Models\Listing;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;
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
            ->with(['category', 'seller'])
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
            $listing->load(['category', 'seller'])
        );
    }

    public function store(Request $request): ListingResource
    {
        $data = $this->validated($request);
        $data['user_id'] = $request->user()->id;
        $data['status'] = 'active';

        if ($request->hasFile('image')) {
            $data['image_path'] = $request->file('image')
                ->store('listings', 'public');
        }

        $listing = Listing::create($data);

        return new ListingResource(
            $listing->load(['category', 'seller'])
        );
    }

    public function update(Request $request, Listing $listing): ListingResource
    {
        $this->authorizeOwner($request, $listing);

        $data = $this->validated($request, true);

        if ($request->hasFile('image')) {
            if ($listing->image_path) {
                Storage::disk('public')->delete($listing->image_path);
            }

            $data['image_path'] = $request->file('image')
                ->store('listings', 'public');
        }

        $listing->update($data);

        return new ListingResource(
            $listing->fresh()->load(['category', 'seller'])
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
            $listing->fresh()->load(['category', 'seller'])
        );
    }

    public function destroy(Request $request, Listing $listing): Response
    {
        $this->authorizeOwner($request, $listing);

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
                ->with(['category', 'seller'])
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
            'available_date' => ['nullable', 'date'],
            'image' => ['nullable', 'image', 'max:5120'],
        ]);
    }
}
