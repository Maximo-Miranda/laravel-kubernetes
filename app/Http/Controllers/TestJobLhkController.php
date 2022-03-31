<?php

namespace App\Http\Controllers;

use App\Jobs\TestLhk;
use Illuminate\Http\Request;

class TestJobLhkController extends Controller
{
    public function index()
    {
        TestLhk::dispatch();

        return response()->json(['message' => 'TestLhk job Successfully']);
    }
}
