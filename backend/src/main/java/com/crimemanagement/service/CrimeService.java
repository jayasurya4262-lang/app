package com.crimemanagement.service;

import com.crimemanagement.model.Crime;
import com.crimemanagement.repository.CrimeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.ArrayList;

@Service
public class CrimeService {
    
    @Autowired
    private CrimeRepository crimeRepository;
    
    public Crime saveCrime(Crime crime) {
        return crimeRepository.save(crime);
    }
    
    public List<Crime> getAllCrimes() {
        return crimeRepository.findAll();
    }
    
    public Crime getCrimeById(String id) {
        return crimeRepository.findById(id).orElse(null);
    }
    
    public List<Crime> getCrimesByType(String crimeType) {
        return crimeRepository.findByCrimeTypeContainingIgnoreCase(crimeType);
    }
    
    public List<Crime> getCrimesByLocation(String location) {
        return crimeRepository.findByLocationContainingIgnoreCase(location);
    }
    
    public List<Crime> searchCrimes(String query) {
        List<Crime> results = new ArrayList<>();
        results.addAll(crimeRepository.findByCrimeTypeContainingIgnoreCase(query));
        results.addAll(crimeRepository.findByLocationContainingIgnoreCase(query));
        results.addAll(crimeRepository.findByDescriptionContainingIgnoreCase(query)); // Search by description too
        return results.stream().distinct().toList();
    }
    
    public Crime updateCrime(String id, Crime crime) {
        if (crimeRepository.existsById(id)) {
            crime.setId(id);
            return crimeRepository.save(crime);
        }
        return null;
    }
    
    public void deleteCrime(String id) {
        crimeRepository.deleteById(id);
    }
}
