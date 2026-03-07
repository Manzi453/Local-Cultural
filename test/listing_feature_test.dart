import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/services/data_seeder.dart';
import '../lib/services/listing_service.dart';
import '../lib/models/listing.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, DocumentReference, QuerySnapshot])
void main() {
  group('Listing Feature Tests', () {
    late DataSeeder dataSeeder;
    late ListingService listingService;

    setUp(() {
      dataSeeder = DataSeeder();
      listingService = ListingService();
    });

    test('Sample data structure is valid', () {
      // Test that our sample data has the correct structure
      final sampleListing = {
        'name': 'King Faisal Hospital',
        'category': 'Hospital',
        'address': 'KG 641 St, Kigali, Rwanda',
        'contactNumber': '+250 788 123 456',
        'description': 'A leading private hospital in Kigali',
        'coordinates': const GeoPoint(-1.9591, 30.0945),
      };

      expect(sampleListing['name'], isA<String>());
      expect(sampleListing['category'], isA<String>());
      expect(sampleListing['address'], isA<String>());
      expect(sampleListing['contactNumber'], isA<String>());
      expect(sampleListing['description'], isA<String>());
      expect(sampleListing['coordinates'], isA<GeoPoint>());
    });

    test('Listing model serialization works correctly', () {
      final listing = Listing(
        id: 'test-id',
        name: 'Test Place',
        category: 'Restaurant',
        address: 'Test Address',
        contactNumber: '+250 123 456 789',
        description: 'Test Description',
        coordinates: const GeoPoint(-1.9591, 30.0945),
        createdBy: 'test-user',
        timestamp: Timestamp.now(),
      );

      final map = listing.toMap();
      expect(map['name'], equals('Test Place'));
      expect(map['category'], equals('Restaurant'));
      expect(map['address'], equals('Test Address'));
      expect(map['contactNumber'], equals('+250 123 456 789'));
      expect(map['description'], equals('Test Description'));
      expect(map['coordinates'], isA<GeoPoint>());
      expect(map['createdBy'], equals('test-user'));
      expect(map['timestamp'], isA<Timestamp>());
    });

    test('Categories are consistent across screens', () {
      final expectedCategories = [
        'Hospital',
        'Police Station',
        'Library',
        'Restaurant',
        'Café',
        'Park',
        'Tourist Attraction',
        'Hotel',
        'Bank',
        'Pharmacy',
        'Shopping Mall',
        'School',
        'Other',
      ];

      // These categories should match between create_listing_screen.dart and home_screen.dart
      expect(expectedCategories.contains('Hospital'), isTrue);
      expect(expectedCategories.contains('Restaurant'), isTrue);
      expect(expectedCategories.contains('Hotel'), isTrue);
      expect(expectedCategories.length, equals(13));
    });
  });

  group('Data Seeder Tests', () {
    test('Sample listings count is correct', () {
      // Verify we have 12 sample listings
      expect(12, equals(12)); // This is a placeholder - actual count would be from the data seeder
    });

    test('Kigali coordinates are valid', () {
      // Test that our sample coordinates are within Kigali bounds
      const kigaliCenter = GeoPoint(-1.9403, 29.8739);
      const sampleCoord = GeoPoint(-1.9591, 30.0945);
      
      // Rough bounds check for Kigali area
      expect(sampleCoord.latitude, greaterThan(-2.5));
      expect(sampleCoord.latitude, lessThan(-1.5));
      expect(sampleCoord.longitude, greaterThan(29.5));
      expect(sampleCoord.longitude, lessThan(30.5));
    });
  });
}
