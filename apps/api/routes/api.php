<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PartnerController;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'service' => 'agrilink-api',
    ]);
});

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function (): void {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::apiResource('partners', PartnerController::class);
});
