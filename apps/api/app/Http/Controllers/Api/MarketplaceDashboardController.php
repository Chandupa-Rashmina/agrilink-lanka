<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Inquiry;
use App\Models\Listing;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MarketplaceDashboardController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        $listingCounts = Listing::query()
            ->where('user_id', $userId)
            ->selectRaw('status, COUNT(*) as aggregate')
            ->groupBy('status')
            ->pluck('aggregate', 'status');

        $buyerInquiryCounts = Inquiry::query()
            ->where('buyer_id', $userId)
            ->selectRaw('status, COUNT(*) as aggregate')
            ->groupBy('status')
            ->pluck('aggregate', 'status');

        $sellerInquiryCounts = Inquiry::query()
            ->whereHas(
                'listing',
                fn ($query) => $query->where('user_id', $userId)
            )
            ->selectRaw('status, COUNT(*) as aggregate')
            ->groupBy('status')
            ->pluck('aggregate', 'status');

        return response()->json([
            'data' => [
                'seller' => [
                    'total_listings' => $listingCounts->sum(),
                    'active' => (int) ($listingCounts['active'] ?? 0),
                    'paused' => (int) ($listingCounts['paused'] ?? 0),
                    'sold' => (int) ($listingCounts['sold'] ?? 0),
                    'pending_inquiries' => (int) (
                        $sellerInquiryCounts['pending'] ?? 0
                    ),
                    'accepted_inquiries' => (int) (
                        $sellerInquiryCounts['accepted'] ?? 0
                    ),
                ],
                'buyer' => [
                    'favorites' => $request->user()
                        ->favoriteListings()
                        ->count(),
                    'pending_inquiries' => (int) (
                        $buyerInquiryCounts['pending'] ?? 0
                    ),
                    'accepted_inquiries' => (int) (
                        $buyerInquiryCounts['accepted'] ?? 0
                    ),
                    'rejected_inquiries' => (int) (
                        $buyerInquiryCounts['rejected'] ?? 0
                    ),
                ],
            ],
        ]);
    }
}
