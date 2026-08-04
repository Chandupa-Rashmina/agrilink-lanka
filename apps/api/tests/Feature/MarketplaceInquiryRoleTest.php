<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Inquiry;
use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MarketplaceInquiryRoleTest extends TestCase
{
    use RefreshDatabase;

    public function test_buyer_and_seller_inquiry_views_are_separated(): void
    {
        $seller = User::factory()->create([
            'phone' => '0770000001',
            'district' => 'Kandy',
        ]);
        $buyer = User::factory()->create([
            'phone' => '0770000002',
            'district' => 'Colombo',
        ]);

        $category = Category::create([
            'name' => 'Vegetables',
            'slug' => 'vegetables',
            'is_active' => true,
        ]);

        $listing = Listing::create([
            'user_id' => $seller->id,
            'category_id' => $category->id,
            'title' => 'Fresh carrots',
            'quantity' => 50,
            'unit' => 'kg',
            'price' => 300,
            'district' => 'Kandy',
            'status' => 'active',
        ]);

        Inquiry::create([
            'listing_id' => $listing->id,
            'buyer_id' => $buyer->id,
            'message' => 'Need 10 kg.',
            'status' => 'pending',
        ]);

        $this->actingAs($buyer, 'sanctum')
            ->getJson('/api/inquiries?role=buyer')
            ->assertOk()
            ->assertJsonPath('data.data.0.role', 'buyer')
            ->assertJsonPath('data.data.0.seller.phone', '0770000001');

        $this->actingAs($seller, 'sanctum')
            ->getJson('/api/inquiries?role=seller')
            ->assertOk()
            ->assertJsonPath('data.data.0.role', 'seller')
            ->assertJsonPath('data.data.0.buyer.phone', '0770000002');
    }
}
