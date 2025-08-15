/**
 * [ranzodium], JNI part of ranzodium
 * Copyright (C) 2025 Zoff <zoff@zoff.cc>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA  02110-1301, USA.
 */

#define _GNU_SOURCE

#include <ctype.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include <sys/types.h>
#include <sys/stat.h>

#include <unistd.h>

#include <fcntl.h>
#include <errno.h>

#include <sodium/utils.h>
#include <sodium.h>

// ------- Android/JNI stuff -------
#include <jni.h>
// ------- Android/JNI stuff -------


// ----------- version -----------
// ----------- version -----------
#define VERSION_MAJOR 0
#define VERSION_MINOR 99
#define VERSION_PATCH 0
static const char global_version_string[] = "0.99.0";
static const char global_version_asan_string[] = "0.99.0-ASAN";
// ----------- version -----------
// ----------- version -----------

#define CLEAR(x) memset(&(x), 0, sizeof(x))

// ----- JNI stuff -----
JNIEnv *jnienv;
JavaVM *cachedJVM = NULL;
// ----- JNI stuff -----

// ------------- JNI -------------
// ------------- JNI -------------
// ------------- JNI -------------

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *jvm, void *reserved)
{
    JNIEnv *env_this;
    cachedJVM = jvm;

    if((*jvm)->GetEnv(jvm, (void **) &env_this, JNI_VERSION_1_6))
    {
        // dbg(0,"Could not get JVM");
        return JNI_ERR;
    }
    // dbg(0,"++ Found JVM ++");
    return JNI_VERSION_1_6;
}

JNIEnv *jni_getenv()
{
    JNIEnv *env_this;
    (*cachedJVM)->GetEnv(cachedJVM, (void **) &env_this, JNI_VERSION_1_6);
    return env_this;
}


JNIEnv *AttachJava()
{
    JavaVMAttachArgs args = {JNI_VERSION_1_6, 0, 0};
    JNIEnv *java;
#ifdef JAVA_LINUX
    (*cachedJVM)->AttachCurrentThread(cachedJVM, (void **)&java, &args);
#else
    (*cachedJVM)->AttachCurrentThread(cachedJVM, &java, &args);
#endif
    return java;
}


JNIEXPORT jstring JNICALL
Java_com_zoffcc_applications_ranzodium_MainClass_getNativeLibGITHASH(JNIEnv *env, jobject thiz)
{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunreachable-code-return"

#if defined(GIT_HASH)
    if (strlen(GIT_HASH) < 2)
    {
        return (*env)->NewStringUTF(env, "00000002");
    }
    else
    {
        return (*env)->NewStringUTF(env, GIT_HASH);
    }
#else
    return (*env)->NewStringUTF(env, "00000001");
#endif

#pragma GCC diagnostic pop
}

JNIEXPORT jstring JNICALL
Java_com_zoffcc_applications_ranzodium_MainClass_libsodium_1version(JNIEnv *env, jobject thiz)
{
    return (*env)->NewStringUTF(env, sodium_version_string());
}

JNIEXPORT jint JNICALL
Java_com_zoffcc_applications_ranzodium_MainClass_init(JNIEnv *env, jobject thiz)
{
    if (sodium_init() < 0) {
        /* panic! the library couldn't be initialized; it is not safe to use */
        return -1;
    }
    return 0;
}

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
JNIEXPORT jlong JNICALL
Java_com_zoffcc_applications_ranzodium_MainClass_get_1random(JNIEnv *env, jobject thiz, jlong upper_bound)
{
    if (upper_bound < 2) {
        // do not use "upper_bound < 2" input values!
        return (jlong)0;
    }
    uint32_t rnd_value = randombytes_uniform((const uint32_t)upper_bound);
    return (jlong)rnd_value;
}





