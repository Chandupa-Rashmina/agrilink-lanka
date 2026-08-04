<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Inquiry;
use App\Models\Listing;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class InquiryController extends Controller
{
    public function store(Request $request, Listing $listing): JsonResponse
    {
        abort_unless($listing->status === 'active', 422);
        abort_if($listing->user_id === $request->user()->id, 422, 'You cannot inquire about your own listing.');

        $data = $request->validate([
            'message' => ['required', 'string', 'max:2000'],
        ]);

        $inquiry = Inquiry::create([
            'listing_id' => $listing->id,
            'buyer_id' => $request->user()->id,
            'message' => $data['message'],
            'status' => 'pending',
        ]);

        return response()->json([
            'data' => $inquiry->load([
                'listing:id,title,user_id',
                'buyer:id,name,email',
            ]),
        ], 201);
    }

    public function mine(Request $request): JsonResponse
    {
        return response()->json([
            'data' => Inquiry::query()
                ->with([
                    'listing:id,title,user_id,status',
                    'buyer:id,name,email',
                ])
                ->where(function ($query) use ($request): void {
                    $query
                        ->where('buyer_id', $request->user()->id)
                        ->orWhereHas('listing', fn ($listing) =>
                            $listing->where('user_id', $request->user()->id));
                })
                ->latest()
                ->paginate(30),
        ]);
    }

    public function update(Request $request, Inquiry $inquiry): JsonResponse
    {
        abort_unless($inquiry->listing->user_id === $request->user()->id, 403);

        $data = $request->validate([
            'status' => ['required', Rule::in(['accepted', 'rejected', 'closed'])],
        ]);

        $inquiry->update($data);

        return response()->json([
            'data' => $inquiry->fresh()->load([
                'listing:id,title,user_id,status',
                'buyer:id,name,email',
            ]),
        ]);
    }
}
