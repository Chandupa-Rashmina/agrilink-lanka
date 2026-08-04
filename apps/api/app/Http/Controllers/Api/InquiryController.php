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
        abort_if(
            $listing->user_id === $request->user()->id,
            422,
            'You cannot inquire about your own listing.'
        );

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
            'data' => $this->serializeInquiry($inquiry->fresh(), $request),
        ], 201);
    }

    public function mine(Request $request): JsonResponse
    {
        $role = $request->validate([
            'role' => ['nullable', Rule::in(['buyer', 'seller'])],
        ])['role'] ?? null;

        $query = Inquiry::query()
            ->with([
                'listing:id,title,user_id,status',
                'buyer:id,name,email,phone,district',
                'listing.seller:id,name,email,phone,district',
            ]);

        if ($role === 'buyer') {
            $query->where('buyer_id', $request->user()->id);
        } elseif ($role === 'seller') {
            $query->whereHas(
                'listing',
                fn ($listing) => $listing->where(
                    'user_id',
                    $request->user()->id
                )
            );
        } else {
            $query->where(function ($nested) use ($request): void {
                $nested
                    ->where('buyer_id', $request->user()->id)
                    ->orWhereHas(
                        'listing',
                        fn ($listing) => $listing->where(
                            'user_id',
                            $request->user()->id
                        )
                    );
            });
        }

        $paginator = $query
            ->latest()
            ->paginate(30)
            ->through(
                fn (Inquiry $inquiry) => $this->serializeInquiry(
                    $inquiry,
                    $request
                )
            );

        return response()->json([
            'data' => $paginator,
        ]);
    }

    public function update(Request $request, Inquiry $inquiry): JsonResponse
    {
        abort_unless(
            $inquiry->listing->user_id === $request->user()->id,
            403
        );

        $data = $request->validate([
            'status' => [
                'required',
                Rule::in(['accepted', 'rejected', 'closed']),
            ],
        ]);

        $inquiry->update($data);

        return response()->json([
            'data' => $this->serializeInquiry(
                $inquiry->fresh(),
                $request
            ),
        ]);
    }

    private function serializeInquiry(
        Inquiry $inquiry,
        Request $request
    ): array {
        $inquiry->loadMissing([
            'listing:id,title,user_id,status',
            'buyer:id,name,email,phone,district',
            'listing.seller:id,name,email,phone,district',
        ]);

        $isSeller = $inquiry->listing->user_id === $request->user()->id;

        return [
            'id' => $inquiry->id,
            'message' => $inquiry->message,
            'status' => $inquiry->status,
            'role' => $isSeller ? 'seller' : 'buyer',
            'listing' => [
                'id' => $inquiry->listing->id,
                'title' => $inquiry->listing->title,
                'status' => $inquiry->listing->status,
            ],
            'buyer' => [
                'id' => $inquiry->buyer->id,
                'name' => $inquiry->buyer->name,
                'email' => $inquiry->buyer->email,
                'phone' => $inquiry->buyer->phone,
                'district' => $inquiry->buyer->district,
            ],
            'seller' => [
                'id' => $inquiry->listing->seller->id,
                'name' => $inquiry->listing->seller->name,
                'email' => $inquiry->listing->seller->email,
                'phone' => $inquiry->listing->seller->phone,
                'district' => $inquiry->listing->seller->district,
            ],
            'created_at' => $inquiry->created_at?->toISOString(),
            'updated_at' => $inquiry->updated_at?->toISOString(),
        ];
    }
}
