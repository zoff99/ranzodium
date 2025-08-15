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

JNIEXPORT jint JNICALL
Java_com_zoffcc_applications_ranzodium_MainClass_get_1random(JNIEnv *env, jobject thiz)
{
    return 3;
}





