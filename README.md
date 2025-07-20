# 📷 PicSor – Picture Sorter App

PicSor is an offline-first Flutter app that helps users clean and organize their local photo and video gallery through intuitive swiping.

Built for both Android and iOS, PicSor enables quick photo triage using left/right/up gestures, with undo history, soft-delete safety, sort-later mode, and detailed storage statistics. Everything runs locally with no backend, and monetization is handled via AdMob.

---

## ✨ Features

- **Swipe to Sort**  
  - 👈 Left to delete (moves to a soft-delete queue)  
  - 👉 Right to keep  
  - ⬆️ Up to sort later  

- **Undo Swipe History**  
  Undo your last swipe with a single tap.

- **Deleted Queue**  
  Review and confirm deletion before photos are permanently removed from device storage.

- **Sort Later Mode**  
  Revisit photos you've set aside and finalize their fate.

- **Swipe Limit System**  
  - 600 swipes per day  
  - +125 swipes every 5 hours  
  - +50 swipes via rewarded AdMob video  
  - Includes anti-time-manipulation protection

- **Statistics Dashboard**  
  - Total storage used by photos  
  - GBs deleted  
  - % of photos reviewed  
  - GBs saved

- **User Interface**  
  - Minimal, responsive UI  
  - Custom icons for share, favorite, and add-to-album  
  - Light, dark, and system theme support  

- **Privacy First**  
  - No backend or account required  
  - All actions are performed locally on device

---

## 📱 Platforms

- ✅ Android (Google Photos support)  
- ✅ iOS (Photos app support)

---

## 🧰 Technologies & Packages

- `photo_manager` – Access and manage local photos/videos  
- `google_mobile_ads` – AdMob integration (rewarded + banners)  
- `shared_preferences` – Local state storage (swipe count, flags)  
- `flutter_local_notifications` – Notification scheduling  
- `permission_handler` – Runtime permission management  
- `path_provider` – Access to cache and temp directories  
- `provider` – State management  

---

Copyright © 2025 Hartvig Solutions

All rights reserved.

This software, PicSor, is the proprietary property of Hartvig Solutions.

Unauthorized copying, distribution, modification, or use of any part of this code or associated assets is strictly prohibited.

You may not:
- Copy, distribute, or publicly display this software
- Use any part of the codebase or design for commercial or educational purposes
- Reverse engineer, decompile, or create derivative works of this software
- Use the app or code in any way that violates applicable laws or regulations

This software is provided “as is,” without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, or noninfringement.

By accessing or using this software, you agree to be bound by these terms.

For licensing inquiries, contact the author directly.
