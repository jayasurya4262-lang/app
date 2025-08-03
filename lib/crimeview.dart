import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/crime.dart';
import 'dart:convert'; // Import for base64Decode
import 'dart:typed_data'; // Import for Uint8List
import 'addcrime.dart'; // Import for the floating action button

class ViewCrime extends StatefulWidget {
  final String userRole; // Pass the user role to this page
  const ViewCrime({Key? key, this.userRole = 'CITIZEN'}) : super(key: key);
  @override
  _ViewCrimeState createState() => _ViewCrimeState();
}

class _ViewCrimeState extends State<ViewCrime> {
  List<Crime> crimes = [];
  List<Crime> filteredCrimes = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  // Define possible crime statuses
  final List<String> crimeStatuses = [
    'REPORTED',
    'UNDER_INVESTIGATION',
    'CRIMINAL_ARRESTED',
    'CLOSED',
  ];

  // Define possible criminal statuses
  final List<String> criminalStatuses = [
    'UNKNOWN',
    'ALIVE',
    'DECEASED',
  ];

  @override
  void initState() {
    super.initState();
    _loadCrimes();
  }

  Future<void> _loadCrimes() async {
    setState(() {
      isLoading = true;
    });

    List<dynamic> fetchedData = await ApiService.getAllCrimes();
    List<Crime> fetchedCrimes = fetchedData.map((json) => Crime.fromJson(json)).toList();
    
    if (!mounted) return;

    setState(() {
      crimes = fetchedCrimes;
      filteredCrimes = fetchedCrimes;
      isLoading = false;
    });
  }

  void _searchCrimes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCrimes = crimes;
      } else {
        filteredCrimes = crimes.where((crime) {
          return crime.crimeType.toLowerCase().contains(query.toLowerCase()) ||
                 crime.location.toLowerCase().contains(query.toLowerCase()) ||
                 crime.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // Function to show the update dialog for admin only
  void _showUpdateCrimeDialog(Crime crime) {
    String? selectedStatus = crime.status;
    String? selectedCriminalStatus = crime.criminalStatus;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Crime Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  hint: const Text('Select Status'),
                  items: crimeStatuses.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedStatus = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Crime Status',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCriminalStatus,
                  hint: const Text('Select Criminal Status'),
                  items: criminalStatuses.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCriminalStatus = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Criminal Status',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () async {
                if (crime.id == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Crime ID is missing.')),
                  );
                  Navigator.of(context).pop();
                  return;
                }

                Crime updatedCrime = crime.copyWith(
                  status: selectedStatus,
                  criminalStatus: selectedCriminalStatus,
                );

                bool success = await ApiService.updateCrime(updatedCrime.id!, updatedCrime.toJson());

                if (mounted) {
                  Navigator.of(context).pop(); // Close the dialog
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Crime record updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadCrimes(); // Reload crimes to reflect changes
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update crime record'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.userRole == 'ADMIN'; // Only admin can edit

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Crimes'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCrimes,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: _searchCrimes,
              decoration: const InputDecoration(
                labelText: 'Search by Crime Type, Location or Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCrimes.isEmpty
                    ? const Center(child: Text('No crimes found'))
                    : ListView.builder(
                        itemCount: filteredCrimes.length,
                        itemBuilder: (context, index) {
                          final crime = filteredCrimes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: crime.crimeType == 'Serial Killer' ? Colors.red : Colors.blue,
                                        child: Icon(
                                          crime.crimeType == 'Serial Killer' ? Icons.dangerous : Icons.warning,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          crime.crimeType,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                      ),
                                      if (crime.status != null)
                                        Chip(
                                          label: Text(crime.status!, style: const TextStyle(color: Colors.white)),
                                          backgroundColor: crime.status == 'REPORTED' ? Colors.orange : (crime.status == 'CRIMINAL_ARRESTED' ? Colors.purple : Colors.green),
                                        ),
                                      if (isAdmin) // Show edit button only for Admin
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _showUpdateCrimeDialog(crime),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Location: ${crime.location}', style: const TextStyle(fontSize: 14)),
                                  Text('Description: ${crime.description}', style: const TextStyle(fontSize: 14)),
                                  if (crime.dateTime != null)
                                    Text('Date: ${crime.dateTime!.toLocal().toString().split('.')[0]}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                  if (crime.criminalStatus != null)
                                    Text('Criminal Status: ${crime.criminalStatus!}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                  
                                  if (crime.images != null && crime.images!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Text('Criminal Images:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 8),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, // Always 2 columns for images
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                        childAspectRatio: 1.0, // Adjusted for smaller, square images
                                      ),
                                      itemCount: crime.images!.length,
                                      itemBuilder: (context, imgIndex) {
                                        try {
                                          Uint8List bytes = base64Decode(crime.images![imgIndex]);
                                          return Container( // Added Container for fixed size
                                            width: 100, // Example fixed width
                                            height: 100, // Example fixed height
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.grey[300]!),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.memory(
                                                bytes,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  debugPrint('Error decoding or loading image: ${crime.images![imgIndex]}, Error: $error');
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child: Icon(Icons.broken_image, color: Colors.grey),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          debugPrint('Error parsing Base64 image: ${crime.images![imgIndex]}, Error: $e');
                                          return Container(
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: Icon(Icons.broken_image, color: Colors.grey),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: widget.userRole == 'ADMIN'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CrimeAddPage()),
                ).then((_) => _loadCrimes()); // Refresh list when returning from add page
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null, // Hide FAB for non-admins
    );
  }
}