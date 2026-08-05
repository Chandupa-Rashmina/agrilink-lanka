<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Inquiry;
use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MarketplaceOperationsTest extends TestCase
{
    use RefreshDatabase;

    public function test_owner_can_pause_resume_and_sell_listing(): void
    {
        $owner = User::factory()->create();
        $listing = $this->listingFor($owner);

        foreach (['paused', 'active', 'sold'] as $status) {
            $this->actingAs($owner, 'sanctum')
                ->patchJson("/api/listings/{$listing->id}/status", [
                    'status' => $status,
                ])
                ->assertOk()
                ->assertJsonPath('data.status', $status);
        }
    }

    public function test_marketplace_filters_and_sorting_work(): void
    {
        $seller = User::factory()->create();
        $category = $this->category();

        Listing::create([
            'user_id' => $seller->id,
            'category_id' => $category->id,
            'title' => 'Cheap negotiable tomato',
            'quantity' => 10,
            'unit' => 'kg',
            'price' => 100,
            'is_negotiable' => true,
            'district' => 'Kandy',
            'status' => 'active',
        ]);

        Listing::create([
            'user_id' => $seller->id,
            'category_id' => $category->id,
            'title' => 'Expensive tomato',
            'quantity' => 10,
            'unit' => 'kg',
            'price' => 500,
            'is_negotiable' => false,
            'district' => 'Kandy',
            'status' => 'active',
        ]);

        $this->getJson(
            '/api/listings?min_price=50&max_price=200'
            .'&negotiable=1&sort=price_low'
        )
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.price', '100.00');
    }

    public function test_marketplace_dashboard_returns_buyer_and_seller_counts(): void
    {
        $seller = User::factory()->create();
        $buyer = User::factory()->create();
        $listing = $this->listingFor($seller);

        $buyer->favoriteListings()->attach($listing->id);

        Inquiry::create([
            'listing_id' => $listing->id,
            'buyer_id' => $buyer->id,
            'message' => 'Need this stock.',
            'status' => 'pending',
        ]);

        $this->actingAs($seller, 'sanctum')
            ->getJson('/api/marketplace-dashboard')
            ->assertOk()
            ->assertJsonPath('data.seller.active', 1)
            ->assertJsonPath('data.seller.pending_inquiries', 1);

        $this->actingAs($buyer, 'sanctum')
            ->getJson('/api/marketplace-dashboard')
            ->assertOk()
            ->assertJsonPath('data.buyer.favorites', 1)
            ->assertJsonPath('data.buyer.pending_inquiries', 1);
    }

    private function listingFor(User $user): Listing
    {
        return Listing::create([
            'user_id' => $user->id,
            'category_id' => $this->category()->id,
            'title' => 'Fresh crop',
            'quantity' => 25,
            'unit' => 'kg',
            'price' => 250,
            'district' => 'Kandy',
            'status' => 'active',
        ]);
    }

    private function category(): Category
    {
        return Category::firstOrCreate(
            ['slug' => 'vegetables'],
            [
                'name' => 'Vegetables',
                'is_active' => true,
            ]
        );
    }
}
