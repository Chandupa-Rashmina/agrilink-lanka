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
        $listings = Listing::query()
            ->with(['category', 'seller'])
            ->visible()
            ->when($request->filled('search'), function ($query) use ($request): void {
                $search = mb_strtolower(
                    trim((string) $request->string('search'))
                );

                $query->where(function ($nested) use ($search): void {
                    $pattern = "%{$search}%";

                    $nested
                        ->whereRaw('LOWER(title) LIKE ?', [$pattern])
                        ->orWhereRaw('LOWER(description) LIKE ?', [$pattern]);
                });
            })
            ->when($request->filled('category_id'), fn ($query) => $query->where('category_id', $request->integer('category_id')))
            ->when($request->filled('district'), fn ($query) => $query->where('district', $request->string('district')))
            ->when($request->filled('min_price'), fn ($query) => $query->where('price', '>=', $request->input('min_price')))
            ->when($request->filled('max_price'), fn ($query) => $query->where('price', '<=', $request->input('max_price')))
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return ListingResource::collection($listings);
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
        abort_unless($listing->user_id === $request->user()->id, 403);

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

    public function destroy(Request $request, Listing $listing): Response
    {
        abort_unless($listing->user_id === $request->user()->id, 403);

        if ($listing->image_path) {
            Storage::disk('public')->delete($listing->image_path);
        }

        $listing->delete();

        return response()->noContent();
    }

    public function mine(Request $request): AnonymousResourceCollection
    {
        return ListingResource::collection(
            Listing::query()
                ->with(['category', 'seller'])
                ->where('user_id', $request->user()->id)
                ->latest()
                ->paginate(20)
        );
    }

    public function markSold(Request $request, Listing $listing): ListingResource
    {
        abort_unless($listing->user_id === $request->user()->id, 403);

        $listing->update(['status' => 'sold']);

        return new ListingResource(
            $listing->fresh()->load(['category', 'seller'])
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
            'title' => [$updating ? 'sometimes' : 'required', 'string', 'max:180'],
            'description' => ['nullable', 'string', 'max:5000'],
            'quantity' => [$updating ? 'sometimes' : 'required', 'numeric', 'gt:0'],
            'unit' => [$updating ? 'sometimes' : 'required', 'string', 'max:40'],
            'price' => [$updating ? 'sometimes' : 'required', 'numeric', 'gte:0'],
            'is_negotiable' => ['sometimes', 'boolean'],
            'district' => [$updating ? 'sometimes' : 'required', 'string', 'max:100'],
            'location' => ['nullable', 'string', 'max:180'],
            'available_date' => ['nullable', 'date'],
            'image' => ['nullable', 'image', 'max:5120'],
            'status' => ['sometimes', Rule::in(['active', 'paused', 'sold'])],
        ]);
    }
}
