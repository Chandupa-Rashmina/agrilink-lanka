<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Inquiry;
use App\Models\Listing;
use App\Models\User;
use Illuminate\Database\Seeder;

class DemoRescueSeeder extends Seeder
{
    public function run(): void
    {
        $this->call(MarketplaceSeeder::class);

        $seller = User::updateOrCreate(
            ['email' => 'seller.demo@agrilink.lk'],
            [
                'name' => 'Nimal Perera',
                'phone' => '+94771234567',
                'district' => 'Kandy',
                'password' => 'DemoSeller123!',
            ],
        );

        $buyer = User::updateOrCreate(
            ['email' => 'buyer.demo@agrilink.lk'],
            [
                'name' => 'Kasun Silva',
                'phone' => '+94779876543',
                'district' => 'Colombo',
                'password' => 'DemoBuyer123!',
            ],
        );

        $rows = [
            [
                'category' => 'Vegetables',
                'title' => 'Fresh Tomatoes',
                'description' => 'Freshly harvested local tomatoes, suitable for retail or restaurant supply.',
                'quantity' => 120,
                'unit' => 'kg',
                'price' => 420,
                'negotiable' => true,
                'district' => 'Kandy',
                'location' => 'Peradeniya',
                'latitude' => 7.2667,
                'longitude' => 80.5960,
                'status' => 'active',
            ],
            [
                'category' => 'Fruits',
                'title' => 'Ambul Bananas',
                'description' => 'Farm-fresh Ambul bananas available in bulk.',
                'quantity' => 250,
                'unit' => 'kg',
                'price' => 310,
                'negotiable' => true,
                'district' => 'Kurunegala',
                'location' => 'Mawathagama',
                'latitude' => 7.4090,
                'longitude' => 80.3150,
                'status' => 'active',
            ],
            [
                'category' => 'Rice and Grains',
                'title' => 'Nadu Paddy',
                'description' => 'Clean Nadu paddy from the latest harvest.',
                'quantity' => 1500,
                'unit' => 'kg',
                'price' => 145,
                'negotiable' => false,
                'district' => 'Anuradhapura',
                'location' => 'Thambuttegama',
                'latitude' => 8.1540,
                'longitude' => 80.3040,
                'status' => 'active',
            ],
            [
                'category' => 'Spices',
                'title' => 'Ceylon Cinnamon',
                'description' => 'Locally processed cinnamon quills for wholesale buyers.',
                'quantity' => 40,
                'unit' => 'kg',
                'price' => 2850,
                'negotiable' => true,
                'district' => 'Galle',
                'location' => 'Karandeniya',
                'latitude' => 6.2600,
                'longitude' => 80.0720,
                'status' => 'active',
            ],
            [
                'category' => 'Coconut Products',
                'title' => 'Mature Coconuts',
                'description' => 'Mature coconuts available directly from the estate.',
                'quantity' => 800,
                'unit' => 'units',
                'price' => 135,
                'negotiable' => true,
                'district' => 'Kurunegala',
                'location' => 'Kuliyapitiya',
                'latitude' => 7.4700,
                'longitude' => 80.0400,
                'status' => 'active',
            ],
            [
                'category' => 'Seeds and Plants',
                'title' => 'Chilli Seedlings',
                'description' => 'Healthy chilli seedlings ready for transplanting.',
                'quantity' => 600,
                'unit' => 'plants',
                'price' => 28,
                'negotiable' => false,
                'district' => 'Matale',
                'location' => 'Dambulla',
                'latitude' => 7.8742,
                'longitude' => 80.6511,
                'status' => 'paused',
            ],
            [
                'category' => 'Fertilizer and Inputs',
                'title' => 'Organic Compost',
                'description' => 'Well-composted organic fertilizer for vegetable and fruit cultivation.',
                'quantity' => 80,
                'unit' => 'bags',
                'price' => 950,
                'negotiable' => true,
                'district' => 'Kandy',
                'location' => 'Gampola',
                'latitude' => 7.1643,
                'longitude' => 80.5696,
                'status' => 'active',
            ],
            [
                'category' => 'Farm Equipment',
                'title' => 'Water Pump',
                'description' => 'Used agricultural water pump in working condition.',
                'quantity' => 1,
                'unit' => 'unit',
                'price' => 48000,
                'negotiable' => true,
                'district' => 'Kegalle',
                'location' => 'Mawanella',
                'latitude' => 7.2523,
                'longitude' => 80.4460,
                'status' => 'sold',
            ],
        ];

        $created = [];

        foreach ($rows as $row) {
            $category = Category::where('name', $row['category'])->firstOrFail();

            $listing = Listing::updateOrCreate(
                [
                    'user_id' => $seller->id,
                    'title' => $row['title'],
                ],
                [
                    'category_id' => $category->id,
                    'description' => $row['description'],
                    'quantity' => $row['quantity'],
                    'unit' => $row['unit'],
                    'price' => $row['price'],
                    'is_negotiable' => $row['negotiable'],
                    'district' => $row['district'],
                    'location' => $row['location'],
                    'latitude' => $row['latitude'],
                    'longitude' => $row['longitude'],
                    'available_date' => now()->toDateString(),
                    'status' => $row['status'],
                ],
            );

            $created[] = $listing;
        }

        $active = collect($created)->firstWhere('status', 'active');

        if ($active) {
            $buyer->favoriteListings()->syncWithoutDetaching([$active->id]);

            Inquiry::updateOrCreate(
                [
                    'listing_id' => $active->id,
                    'buyer_id' => $buyer->id,
                ],
                [
                    'message' => 'Is this still available? I am interested in buying in bulk.',
                    'status' => 'pending',
                ],
            );
        }
    }
}
