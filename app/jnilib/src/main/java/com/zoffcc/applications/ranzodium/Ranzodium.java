/**
 * [ranzodium], Java part of ranzodium
 * Copyright (C) 2025 Zoff <zoff@zoff.cc>
 * <p>
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the Free Software Foundation.
 * <p>
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * <p>
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA  02110-1301, USA.
 */

package com.zoffcc.applications.ranzodium;

import android.util.Log;

public class Ranzodium
{
    private static final String TAG = "Ranzodium";

    static boolean native_lib_loaded = false;

    public static native String getNativeLibGITHASH();

    public static native String libsodium_version();

    /*
     * 
     * The sodium_init() function must be called before any other function.
     * It is safe to call sodium_init() multiple times or from different threads;
     * returns 0 if it is ok, -1 on error.
     * 
    */
    public static native int init();

    /*
     *
     * The randombytes_uniform() function returns an unpredictable value
     * between 0 and upper_bound (excluded).
     * 
     * Unlike randombytes_random() % upper_bound, it guarantees a uniform distribution of
     * the possible output values even when upper_bound is not a power of 2.
     * 
     * Note that an upper_bound < 2 leaves only a single element to be chosen, namely 0
     * 
     */
    public static native long get_1random(long upper_bound);

    /*
     * this is used to load the native library on
     * application startup. The library has already been unpacked at
     * installation time by the package manager.
     */
    static
    {
        try
        {
            System.loadLibrary("jni-ranzodium");
            native_lib_loaded = true;
            try
            {
                Log.i(TAG, "successfully loaded ranzodium jni library: " + libsodium_version());
            }
            catch(Exception e2)
            {
                Log.i(TAG, "successfully loaded ranzodium jni library");
            }
        }
        catch (java.lang.UnsatisfiedLinkError e)
        {
            native_lib_loaded = false;
            Log.i(TAG, "loadLibrary ranzodium jni failed!");
            e.printStackTrace();
        }
    }
}

