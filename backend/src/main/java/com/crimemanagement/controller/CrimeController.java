package com.crimemanagement.controller;

import com.crimemanagement.model.Crime;
import com.crimemanagement.service.CrimeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/crimes")
@CrossOrigin(origins = "*")
public class CrimeController {
    
    @Autowired
    private CrimeService crimeService;
  
    @PostMapping
    public ResponseEntity<Crime> createCrime(@RequestBody Crime crime) {
        // Log the incoming crime object for debugging
        System.out.println("Received crime for creation: " + crime.getCrimeType() + " at " + crime.getLocation());
        if (crime.getImages() != null && !crime.getImages().isEmpty()) {
            System.out.println("Received " + crime.getImages().size() + " images (Base64 strings).");
        }

        // Set server-side properties that are not sent from client or need to be set on creation
        crime.setDateTime(LocalDateTime.now());
        crime.setStatus("REPORTED");
        crime.setCriminalStatus("UNKNOWN"); // Set default criminal status on creation

        // Handle Serial Killer specific properties based on crimeType
        if ("Serial Killer".equalsIgnoreCase(crime.getCrimeType())) {
            crime.setPriority("HIGH");
            crime.setAlertLevel("CRITICAL");
            crime.setSpecialUnit("Criminal Investigation Department");
            crime.setRequiresImmediateAttention(true);
        } else {
            crime.setPriority("MEDIUM");
            crime.setAlertLevel("NORMAL");
            crime.setRequiresImmediateAttention(false);
        }

        try {
            Crime savedCrime = crimeService.saveCrime(crime);
            System.out.println("Crime saved successfully with ID: " + savedCrime.getId());
            return ResponseEntity.ok(savedCrime);
        } catch (Exception e) {
            System.err.println("Error saving crime: " + e.getMessage());
            e.printStackTrace(); // Print full stack trace for detailed error
            return ResponseEntity.status(500).build(); // Return 500 Internal Server Error
        }
    }
    
    @GetMapping
    public ResponseEntity<List<Crime>> getAllCrimes() {
        List<Crime> crimes = crimeService.getAllCrimes();
        return ResponseEntity.ok(crimes);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Crime> getCrimeById(@PathVariable String id) {
        Crime crime = crimeService.getCrimeById(id);
        if (crime != null) {
            return ResponseEntity.ok(crime);
        }
        return ResponseEntity.notFound().build();
    }
    
    @GetMapping("/type/{crimeType}")
    public ResponseEntity<List<Crime>> getCrimesByType(@PathVariable String crimeType) {
        List<Crime> crimes = crimeService.getCrimesByType(crimeType);
        return ResponseEntity.ok(crimes);
    }
    
    @GetMapping("/location/{location}")
    public ResponseEntity<List<Crime>> getCrimesByLocation(@PathVariable String location) {
        List<Crime> crimes = crimeService.getCrimesByLocation(location);
        return ResponseEntity.ok(crimes);
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<Crime>> searchCrimes(@RequestParam String query) {
        List<Crime> crimes = crimeService.searchCrimes(query);
        return ResponseEntity.ok(crimes);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Crime> updateCrime(@PathVariable String id, @RequestBody Crime crime) {
        // Log the incoming crime object for debugging
        System.out.println("Received crime for update (ID: " + id + "): " + crime.getCrimeType() + " Status: " + crime.getStatus() + " Criminal Status: " + crime.getCriminalStatus());

        if (crimeService.getCrimeById(id) != null) { // Check if crime exists
            crime.setId(id); // Ensure the ID is set for update
            // The saveCrime method will handle updating the existing record
            Crime updatedCrime = crimeService.saveCrime(crime); 
            System.out.println("Crime updated successfully with ID: " + updatedCrime.getId());
            return ResponseEntity.ok(updatedCrime);
        }
        System.err.println("Crime with ID " + id + " not found for update.");
        return ResponseEntity.notFound().build();
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCrime(@PathVariable String id) {
        crimeService.deleteCrime(id);
        return ResponseEntity.noContent().build();
    }
}
