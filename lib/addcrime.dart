import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'services/api_service.dart';
import 'models/crime.dart';
import 'dart:typed_data'; // For Uint8List

class CrimeAddPage extends StatefulWidget {
  const CrimeAddPage({Key? key}) : super(key: key);
  @override
  _CrimeAddPageState createState() => _CrimeAddPageState();
}

class _CrimeAddPageState extends State<CrimeAddPage> {
  String? selectedCrimeType;
  String? location;
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;
  
  final ImagePicker _picker = ImagePicker();
  List<Uint8List> selectedImages = []; // Store images as Uint8List

  int get currentMaxImages {
    if (selectedCrimeType == 'Serial Killer') {
      return 4;
    }
    return 1;
  }

  List<String> crimeTypes = [
    'Murder',
    'Robbery',
    'Theft',
    'Assault',
    'Kidnapping',
    'Cyber Crime',
    'Domestic Violence',
    'Human Trafficking',
    'Drug Trafficking',
    'Sexual Harassment',
    'Serial Killer',
  ];

  List<String> locations = [
    'Erode', 'Perundurai', 'Gobichettipalayam', 'Bhavani', 'Chennimalai',
    'Kodumudi', 'Sathyamangalam', 'Anthiyur', 'Modakurichi', 'Kanjikoil',
    'Kavindapadi', 'Pallipalayam', 'Nasiyanur', 'Ammapet', 'Thindal',
    'Kollampalayam', 'Surampatti', 'Lakshmi Nagar', 'Veerappanchatram',
    'Arachalur', 'Nambiyur', 'Thingalur', 'Pasur', 'Velampalayam',
    'Chitode', 'Kavundapadi', 'Periyasemur', 'Unjalur', 'Kanagaraj Nagar',
    'Pallathur', 'Avalpoondurai', 'Pungambadi', 'Soolai', 'Kaspapettai',
    'Veppampalayam', 'Thalavaipalayam', 'Kudagupalayam', 'Perumandampalayam',
    'Kodumudi Road', 'Karungalpalayam', 'Karattadipalayam', 'Vellode',
    'Appakudal', 'Kalingarayanpalayam', 'Nerinjipettai', 'Kanjirankombai',
    'Nadarmedu', 'Olagadam', 'Polavapalayam', 'Mylambadi',
  ];

  Future<void> _pickImageFromGallery() async {
    if (selectedImages.length >= currentMaxImages) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maximum ${currentMaxImages} images allowed for this crime type')),
        );
      }
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final Uint8List bytes = await image.readAsBytes(); // Read as bytes
        if (!mounted) return;
        setState(() {
          if (currentMaxImages == 1) {
            selectedImages.clear();
          }
          selectedImages.add(bytes); // Add bytes directly
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  Future<void> _submitCrime() async {
    if (selectedCrimeType == null || location == null || descriptionController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    Crime crime = Crime(
      crimeType: selectedCrimeType!,
      location: location!,
      description: descriptionController.text,
      reportedBy: 'Admin',
      // images will be added by ApiService.addCrime
    );

    bool success = await ApiService.addCrime(crime.toJson(), selectedImages);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Crime record added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      setState(() {
        selectedCrimeType = null;
        location = null;
        descriptionController.clear();
        selectedImages.clear();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add crime record'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Crime Record'),
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: selectedCrimeType,
                  hint: const Text('Select Crime Type'),
                  items: crimeTypes.map((String crime) {
                    return DropdownMenuItem<String>(
                      value: crime,
                      child: Row(
                        children: [
                          Icon(
                            crime == 'Serial Killer' ? Icons.dangerous : Icons.warning,
                            color: crime == 'Serial Killer' ? Colors.red : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(crime),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCrimeType = newValue;
                      selectedImages.clear();
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Crime Type *',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: location,
                  hint: const Text('Select Crime Location'),
                  items: locations.map((String erodelocation) {
                    return DropdownMenuItem<String>(
                      value: erodelocation,
                      child: Text(erodelocation),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      location = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Location *',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Crime Description *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    hintText: 'Provide detailed description of the crime...',
                  ),
                  maxLines: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.photo_camera, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Criminal Images (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedCrimeType == 'Serial Killer'
                          ? 'Add up to ${currentMaxImages} images of suspects or crime scene for Serial Killer cases.'
                          : 'Add 1 image of suspect or crime scene for this crime type.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (selectedImages.length < currentMaxImages)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _pickImageFromGallery,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text('Add Image (${selectedImages.length}/${currentMaxImages})'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[50],
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),

                    if (selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Selected Images:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: selectedCrimeType == 'Serial Killer' ? 2 : 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: selectedCrimeType == 'Serial Killer' ? 1 : 1.5,
                        ),
                        itemCount: selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory( // Use Image.memory for Uint8List
                                    selectedImages[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitCrime,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Submitting...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text(
                            'Submit Crime Report',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              '* Required fields',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
