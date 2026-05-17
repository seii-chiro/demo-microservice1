<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\SampleController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware();

Route::get('/hello', function () {
    return ['message' => 'Hello, This is from Microservice 1!'];
})->middleware();

Route::get('/sample', [SampleController::class, 'index'])->middleware();