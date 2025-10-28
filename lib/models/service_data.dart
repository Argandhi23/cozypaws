import 'service.dart';
import 'grooming.dart';
import 'boarding.dart';
import 'vaksinasi.dart';
import 'service_packages.dart';
import 'antarjemput.dart';

class ServiceData {
  static List<Service> getServices() {
    return [
      Grooming(
        id: "1",
        name: "Grooming",
        price: 50000,
        description:
            "Karena meow juga butuh me-time~ biar makin paw-lush dan wangi cuddly!",
        imageUrl: "assets/images/grooming.png",
        breed: "Kusyink",
        duration: 30,
        packages: [
          ServicePackage(
            name: "Meow Glow",
            price: 50000,
            facilities: ["Sisir Bulu", "Potong Kuku"],
          ),
          ServicePackage(
            name: "Kitty Fresh",
            price: 85000,
            facilities: ["Sisir Bulu", "Potong Kuku", "Bath Fresh", "Blow Dry"],
          ),
          ServicePackage(
            name: "Pawfect Care",
            price: 120000,
            facilities: [
              "Sisir Bulu",
              "Potong Kuku",
              "Bubble Bath",
              "Fur Drying",
              "Pembersihan Telinga",
            ],
          ),
          ServicePackage(
            name: "Royal Treatmeow",
            price: 185000,
            facilities: [
              "Sisir Bulu",
              "Potong Kuku",
              "Clean & Fresh Bath",
              "Blow Pawfect",
              "Pembersihan Telinga",
              "Pawfum Spray",
            ],
          ),
        ],
      ),
      Boarding(
        id: "2",
        name: "Boarding",
        price: 70000,
        description:
            "Liburan, ada acara, atau lagi sibuk? Jangan khawatir, biar si meow staycation di sini.",
        imageUrl: "assets/images/boarding.png",
        breed: "Persia",
        days: 1,
        includeFood: true,
        packages: [
          ServicePackage(
            name: "Nap Pawlace",
            price: 70000,
            facilities: ["Ruang Nyaman", "Makanan 2x sehari", "Air Minum"],
          ),
          ServicePackage(
            name: "Meowtel",
            price: 120000,
            facilities: [
              "Ruang Nyaman",
              "Makanan 3x sehari",
              "Air Minum",
              "Paw Playtime",
            ],
          ),
          ServicePackage(
            name: "Pawcation",
            price: 180000,
            facilities: [
              "Suite Premium",
              "Makanan Premium 3x sehari",
              "Air Minum",
              "Paw Playtime",
              "Growmeow Treats",
            ],
          ),
          ServicePackage(
            name: "Royal SuiteMeow",
            price: 250000,
            facilities: [
              "Suite VIP Ber-AC",
              "Makanan Super Premium",
              "Air Minum",
              "Paw Playtime",
              "Growmeow Treats",
              "Foto Pawtrait",
            ],
          ),
        ],
      ),
      Vaksinasi(
        id: "3",
        name: "Vaksinasi",
        price: 80000,
        description:
            "Meowtection time! Jaga kesehatan si meow dengan vaksin biar tetap aktif, sehat, dan bebas dari penyakit!.",
        imageUrl: "assets/images/vaksin.png",
        vaccineType: "Rabies",
        breed: "Domestic",
        packages: [
          ServicePackage(
            name: "MeowShield",
            price: 80000,
            facilities: ["Vaksin Dasar", "Kartu Vaksin"],
          ),
          ServicePackage(
            name: "Pawtection",
            price: 150000,
            facilities: ["Vaksin Dasar", "Vaksin Lanjutan", "Kartu Vaksin"],
          ),
          ServicePackage(
            name: "FurGuard",
            price: 220000,
            facilities: [
              "Vaksin Dasar",
              "Vaksin Lanjutan",
              "Cek Kesehatan Ringan",
              "Kartu Vaksin",
            ],
          ),
          ServicePackage(
            name: "Royal Puurtection",
            price: 300000,
            facilities: [
              "Vaksin Dasar",
              "Vaksin Lanjutan",
              "Vaksin Lengkap",
              "Cek Kesehatan Lengkap",
              "Kartu Vaksin Eksklusif",
              "Foto Pawtrait",
            ],
          ),
        ],
      ),
      AntarJemput(
        id: "4",
        name: "Pick-up & Drop of",
        price: 30000,
        description: "Jemput dan antar paw kesayanganmu sampai Cozy Paws",
        imageUrl: "assets/images/antarjemput.png",
        packages: [
          ServicePackage(
            name: "Dalam Kota",
            price: 30000,
            facilities: ["Jemput dari rumah", "Antar kembali", "Maks 10 km"],
          ),
          ServicePackage(
            name: "Luar Kota",
            price: 60000,
            facilities: ["Jemput dari rumah", "Antar kembali", "Maks 25 km"],
          ),
          ServicePackage(
            name: "VIP Ride",
            price: 100000,
            facilities: [
              "Mobil khusus AC",
              "CozyNest",
              "Snack meow gratis",
              "Maks 30 km",
            ],
          ),
        ],
        area: "Dalam Kota",
        distance: 10,
      ),
    ];
  }
}
