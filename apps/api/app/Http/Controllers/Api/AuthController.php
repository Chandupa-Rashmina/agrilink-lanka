<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['required', 'string', 'max:30'],
            'district' => ['required', 'string', 'max:100'],
            'password' => ['required', 'confirmed', Password::min(8)],
            'device_name' => ['nullable', 'string', 'max:100'],
        ]);

        $user = User::create([
            'name' => $data['name'],
            'email' => mb_strtolower($data['email']),
            'phone' => $data['phone'],
            'district' => $data['district'],
            'password' => $data['password'],
        ]);

        return $this->tokenResponse(
            $user,
            $data['device_name'] ?? 'android',
            201,
        );
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::query()
            ->where('email', mb_strtolower($request->validated('email')))
            ->first();

        if (! $user || ! Hash::check(
            $request->validated('password'),
            $user->password
        )) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        return $this->tokenResponse(
            $user,
            $request->validated('device_name', 'android'),
        );
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'data' => $this->userData($request->user()),
        ]);
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => [
                'required',
                'email',
                'max:255',
                Rule::unique('users', 'email')->ignore($user->id),
            ],
            'phone' => ['required', 'string', 'max:30'],
            'district' => ['required', 'string', 'max:100'],
        ]);

        $user->update([
            ...$data,
            'email' => mb_strtolower($data['email']),
        ]);

        return response()->json([
            'data' => $this->userData($user->fresh()),
        ]);
    }

    public function logout(Request $request): Response
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->noContent();
    }

    private function tokenResponse(
        User $user,
        string $deviceName,
        int $status = 200,
    ): JsonResponse {
        $token = $user->createToken($deviceName)->plainTextToken;

        return response()->json([
            'data' => [
                'user' => $this->userData($user),
                'token' => $token,
            ],
        ], $status);
    }

    private function userData(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'district' => $user->district,
        ];
    }
}
