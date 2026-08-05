<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('listing_images', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('listing_id')
                ->constrained()
                ->cascadeOnDelete();
            $table->string('path');
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();

            $table->unique(['listing_id', 'path']);
            $table->index(['listing_id', 'sort_order']);
        });

        DB::table('listings')
            ->whereNotNull('image_path')
            ->orderBy('id')
            ->eachById(function (object $listing): void {
                DB::table('listing_images')->insert([
                    'listing_id' => $listing->id,
                    'path' => $listing->image_path,
                    'sort_order' => 0,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            });
    }

    public function down(): void
    {
        Schema::dropIfExists('listing_images');
    }
};
