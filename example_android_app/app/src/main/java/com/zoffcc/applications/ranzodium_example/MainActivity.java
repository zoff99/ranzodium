package com.zoffcc.applications.ranzodium_example;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.zoffcc.applications.ranzodium.Ranzodium;

import java.util.Random;

/** @noinspection TextBlockMigration, SpellCheckingInspection , InstantiationOfUtilityClass , UnnecessaryLocalVariable , ExplicitArrayFilling , unused */
public class MainActivity extends Activity
{
    static final String TAG = "RanzodiumExample";
    static final boolean USE_JAVA_RANDOM = false; // try the java random number generator
    TextView text_view;
    ImageView image_view;

    @SuppressLint("SetTextI18n")
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        text_view = this.findViewById(R.id.text_window);
        image_view = this.findViewById(R.id.image1);
    }

    @SuppressLint("SetTextI18n")
    @Override
    protected void onResume()
    {
        super.onResume();
        final String jni_version_hash = Ranzodium.getNativeLibGITHASH();
        final String libsodium_version_string = Ranzodium.libsodium_version();
        text_view.setText(jni_version_hash + " - " +
                          libsodium_version_string + "\n" +
                          "random value = " + Ranzodium.get_random(10_000));
        text_view.setVisibility(View.VISIBLE);
        test_randomness();
    }

    @SuppressLint({"SetTextI18n", "DefaultLocale"})
    private void test_randomness()
    {
        final long t1 = System.currentTimeMillis();
        final int loops = 10_000;
        final int range = 300;
        final long[] result = new long[range];

        text_view.setText(text_view.getText() + "\n" +
                          "l: " + String.format("%,d", loops).replace(",", "_") + " r: " + range);

        // init the array
        for (int i=0;i<range;i++)
        {
            result[i] = 0;
        }

        // run random number generator
        Random ran = null;
        if (USE_JAVA_RANDOM)
        {
            ran = new Random();
            text_view.setText(text_view.getText() + "\n" + "using Java Random");
        }
        else
        {
            text_view.setText(text_view.getText() + "\n" + "using libsodium Random");
        }
        long rnd;
        for (int i=0;i<loops;i++)
        {
            if (USE_JAVA_RANDOM)
            {
                rnd = ran.nextInt(range);
            }
            else
            {
                rnd = Ranzodium.get_random(range);
            }
            result[(int) rnd]++;
        }

        // find largest result
        int largest_result = 0;
        for (int i=0;i<range;i++)
        {
            if (result[i] > largest_result)
            {
                largest_result = (int) result[i];
            }
        }
        // find largest result
        Log.i(TAG, "largest_result:" + largest_result);

        // find lowest result
        int lowest_result = largest_result;
        for (int i=0;i<range;i++)
        {
            if (result[i] < lowest_result)
            {
                lowest_result = (int) result[i];
            }
        }
        // find lowest result
        Log.i(TAG, "lowest_result:" + lowest_result);

        text_view.setText(text_view.getText() + "\n" +
                          "low: " + lowest_result +
                          " high: " + largest_result +
                          " delta: " + (largest_result - lowest_result));

        // put results into image
        final int w = range;
        final int h = largest_result + 20;
        Bitmap result_bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
        final int col = Color.BLUE;
        for (int i=0;i<range;i++)
        {
            // Log.i(TAG, "result:" + i + " result=" + result[i] + " loops=" + loops + " h=" + h);
            for (int yy=0;yy<result[i];yy++)
            {
                result_bitmap.setPixel(i, (h - yy) - 1, col);
            }
        }

        image_view.setImageBitmap(result_bitmap);

        // measure the test duration and show it
        final long t2 = System.currentTimeMillis();
        text_view.setText(text_view.getText() + "\n" +
                          "test: " + ((t2 - t1)) + " ms");
    }

    static {
        Ranzodium dummy = new Ranzodium(); // to load the JNI library
        final String jni_version_string = Ranzodium.getNativeLibGITHASH();
        final String libsodium_version_string = Ranzodium.libsodium_version();
        Ranzodium.init();
        Log.i(TAG, "JNI version: " + jni_version_string + " libsodium version: " + libsodium_version_string);
    }
}
