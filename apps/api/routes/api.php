<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\InquiryController;
use App\Http\Controllers\Api\ListingController;
use App\Http\Controllers\Api\MarketplaceDashboardController;
use App\Http\Controllers\Api\PartnerController;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'service' => 'agrilink-api',
    ]);
});

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/listings', [ListingController::class, 'index']);
Route::get('/listings/{listing}', [ListingController::class, 'show']);

Route::middleware('auth:sanctum')->group(function (): void {
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::apiResource('partners', PartnerController::class);

    Route::get('/marketplace-dashboard', MarketplaceDashboardController::class);
    Route::get('/listings/{listing}/contact', [ListingController::class, 'contact']);
    Route::get('/my-listings', [ListingController::class, 'mine']);
    Route::post('/listings', [ListingController::class, 'store']);
    Route::match(['put', 'patch'], '/listings/{listing}', [ListingController::class, 'update']);
    Route::delete('/listings/{listing}', [ListingController::class, 'destroy']);
    Route::patch('/listings/{listing}/status', [ListingController::class, 'updateStatus']);
    Route::post('/listings/{listing}/sold', [ListingController::class, 'markSold']);

    Route::post('/listings/{listing}/inquiries', [InquiryController::class, 'store']);
    Route::get('/inquiries', [InquiryController::class, 'mine']);
    Route::patch('/inquiries/{inquiry}', [InquiryController::class, 'update']);

    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::post('/favorites/{listing}', [FavoriteController::class, 'store']);
    Route::delete('/favorites/{listing}', [FavoriteController::class, 'destroy']);
});
