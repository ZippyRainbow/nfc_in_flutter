package me.andisemler.nfc_in_flutter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;

public class NfcInFlutterPlugin implements FlutterPlugin, ActivityAware {
    private @Nullable FlutterPluginBinding flutterPluginBinding;
    private @Nullable MethodCallHandlerImpl methodCallHandler;
    private @Nullable MethodChannel channel;

    public NfcInFlutterPlugin() {
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        this.flutterPluginBinding = binding;
        // Initialize method channel
        channel = new MethodChannel(binding.getBinaryMessenger(), "nfc_in_flutter");
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        // Clean up engine references
        if (channel != null) {
            channel.setMethodCallHandler(null);
            channel = null;
        }
        this.flutterPluginBinding = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        if (flutterPluginBinding == null) {
            return;
        }

        methodCallHandler = new MethodCallHandlerImpl(
                binding.getActivity(),
                flutterPluginBinding.getBinaryMessenger()
        );

        // Set up method channel handler
        if (channel != null) {
            channel.setMethodCallHandler(methodCallHandler);
        }

        // Register for new intents
        binding.addOnNewIntentListener(methodCallHandler);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        if (methodCallHandler != null) {
            methodCallHandler.stopListening();
            methodCallHandler = null;
        }

        // Clear method channel handler when detached from activity
        if (channel != null) {
            channel.setMethodCallHandler(null);
        }
    }
}