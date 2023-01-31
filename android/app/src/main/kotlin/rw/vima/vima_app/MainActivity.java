package rw.vima.vima_app;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.verify.domain.DomainVerificationManager;
import android.content.pm.verify.domain.DomainVerificationUserState;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onNewIntent(@NotNull Intent intent) {
        super.onNewIntent(intent);
        runInt(intent);
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        Intent intent = getIntent();
        runInt(intent);
    }

    private boolean checkVerified() {

        try{

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                Context context = getContext();
                DomainVerificationManager manager = null;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    manager = context.getSystemService(DomainVerificationManager.class);
                }

                DomainVerificationUserState userState =
                        null;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    userState = manager.getDomainVerificationUserState(context.getPackageName());
                }

                Map<String, Integer> hostToStateMap = null;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    hostToStateMap = userState.getHostToStateMap();
                }

                if(hostToStateMap != null) {
                    for (String key : hostToStateMap.keySet()) {
                        Integer stateValue = hostToStateMap.get(key);
                        if (stateValue != null && stateValue == DomainVerificationUserState.DOMAIN_STATE_VERIFIED) {
                            // Domain has passed Android App Links verification.
                            return true;
                        }
                    }
                }
            }


            return false;
        }catch (PackageManager.NameNotFoundException ignored){

            return false;
        }

    }


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);


        MethodChannel methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "app.channel.shared.data");
        methodChannel.setMethodCallHandler(
                (call, result) -> {
                     if (call.method.contentEquals("deep-link")) {
                        result.success(url);
                        url = null;
                    }else if(call.method.contentEquals("open-verify-page")){
                         Intent intent = null;
                         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                             intent = new Intent(Settings.ACTION_APP_OPEN_BY_DEFAULT_SETTINGS,
                                     Uri.parse("package:${context.packageName}"));
                             getContext().startActivity(intent);
                         }
                         result.success("result");
                     }else if(call.method.contentEquals("check-verified")){
                         result.success(checkVerified());
                     } else {
                         result.success("result");
                     }
                });


    }


    String url;

    private void runInt(Intent intent) {


        if (intent.getData() != null) {
            //val action = intent.action
            url = intent.getData().toString();
        }
    }

}
