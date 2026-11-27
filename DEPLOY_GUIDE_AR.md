# دليل نشر منصة TRUST IN MED (GitHub + السيرفر السحابي + APK + Google Play Store)

## 1. النشر المجاني على GitHub Pages
1. أنشئ مستودعاً جديداً (New Repository) على [GitHub](https://github.com/new) باسم `trust-in-med` واجعله Public.
2. ارفع الملفات الموجودة في هذه الحزمة (`index.html`, `manifest.json`, `sw.js`) إلى الفرع الرئيسي `main`.
3. ادخل إلى **Settings → Pages** داخل المستودع، واختر **Branch: main** ثم اضغط **Save**.
4. خلال دقيقة واحدة سيعمل تطبيقك على الرابط: `https://<username>.github.io/trust-in-med/` (ويعمل كتطبيق PWA على الهواتف).

## 2. السيرفر وقاعدة البيانات السحابية (Supabase)
1. أنشئ مشروعاً مجانياً على [Supabase](https://supabase.com/).
2. من **SQL Editor** الصق محتوى ملف `supabase_schema.sql` واضغط **Run**.
3. من **Storage** أنشئ Bucket جديد باسم `trustinmed-vault` واجعله **Public للقراءة فقط**، وأضف سياسات Storage تمنع الرفع والحذف إلا للمستخدمين المسجلين — لا تجعل الكتابة عامة أبداً.
4. انسخ `Project URL` و`Anon Public Key` من **Project Settings → API** وأدخلهما داخل صفحة **الإعدادات والمزامنة** في تطبيق TRUST IN MED.

> **تنبيه أمني (إصلاح 2026-11-28):** سياسات RLS في `supabase_schema.sql` كانت تسمح لأي شخص على الإنترنت بالكتابة والحذف بدون تسجيل دخول (`using (true)`). النسخة المصححة تشترط تسجيل الدخول للقراءة والكتابة. لا ترجع للسياسات العامة أبداً، ولا تضع مفتاح `service_role` في أي ملف عميل.

## 3. تحويل التطبيق إلى Android APK و AAB للنشر في Google Play Store
1. ثبّت [Node.js](https://nodejs.org/) و[Android Studio](https://developer.android.com/studio).
2. فك ضغط هذه الحزمة وانسخ `index.html` و`manifest.json` و`sw.js` داخل مجلد باسم `www/`.
3. شغّل الأوامر التالية في الطرفية:
   ```bash
   npm install
   npx cap add android
   npx cap sync android
   npx cap open android
   ```
4. داخل Android Studio:
   - لإنتاج ملف **APK** للتجربة المباشرة: **Build → Build Bundle(s) / APK(s) → Build APK(s)**.
   - لإنتاج ملف **AAB** الموقّع لرفعه على **Google Play Console**: **Build → Generate Signed Bundle / APK → Android App Bundle (.aab)** ثم أنشئ مفتاح توقيع (Keystore) واحتفظ به بأمان، وارفع ملف `.aab` في [Google Play Console](https://play.google.com/console).
