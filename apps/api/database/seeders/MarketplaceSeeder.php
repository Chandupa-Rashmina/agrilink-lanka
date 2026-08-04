<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class MarketplaceSeeder extends Seeder
{
    public function run(): void
    {
        foreach ([
            'Vegetables',
            'Fruits',
            'Rice and Grains',
            'Spices',
            'Coconut Products',
            'Dairy',
            'Livestock',
            'Seeds and Plants',
            'Fertilizer and Inputs',
            'Farm Equipment',
        ] as $name) {
            Category::updateOrCreate(
                ['slug' => Str::slug($name)],
                ['name' => $name, 'is_active' => true],
            );
        }
    }
}
