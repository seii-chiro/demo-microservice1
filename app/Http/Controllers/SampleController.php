<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Sample;

class SampleController extends Controller
{
    public function index()
    {
        $sample = Sample::query()->first();
        $messageFromDatabase = $sample?->message ?? 'No message found in the database.';
        return response()->json(['message' => $messageFromDatabase]);
    }
}
