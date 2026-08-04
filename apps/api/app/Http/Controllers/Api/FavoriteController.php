<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ListingResource;
use App\Models\Listing;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class FavoriteController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $listings = $request->user()
            ->favoriteListings()
            ->with(['category', 'seller'])
            ->where('listings.status', 'active')
            ->orderByDesc('favorites.created_at')
            ->paginate(20);

        return ListingResource::collection($listings);
    }

    public function store(Request $request, Listing $listing): JsonResponse
    {
        abort_unless($listing->status === 'active', 422);

        $request->user()
            ->favoriteListings()
            ->syncWithoutDetaching([$listing->id]);

        return response()->json([
            'message' => 'Listing saved.',
        ]);
    }

    public function destroy(Request $request, Listing $listing): JsonResponse
    {
        $request->user()
            ->favoriteListings()
            ->detach($listing->id);

        return response()->json([
            'message' => 'Listing removed from favorites.',
        ]);
    }
}
