<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('listings', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('category_id')->constrained()->restrictOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->decimal('quantity', 12, 2);
            $table->string('unit', 40);
            $table->decimal('price', 12, 2);
            $table->boolean('is_negotiable')->default(false);
            $table->string('district', 100);
            $table->string('location')->nullable();
            $table->date('available_date')->nullable();
            $table->string('image_path')->nullable();
            $table->string('status', 30)->default('active');
            $table->timestamps();

            $table->index(['status', 'category_id']);
            $table->index(['district', 'status']);
            $table->index(['user_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('listings');
    }
};
