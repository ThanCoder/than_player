# audio_service package အတွက် keep လုပ်ခြင်း
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.audio_service.** { *; }

# Background မှာ အလုပ်လုပ်မယ့် Custom Audio Handler အတွက် (ကိုယ့် package name အတိုင်း ပြောင်းပေးရန်)
# ဥပမာ - com.example.myapp ဖြစ်ပါက
-keep class than.app.than_player.** { *; }