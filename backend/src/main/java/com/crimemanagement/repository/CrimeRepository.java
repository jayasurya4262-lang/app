package com.crimemanagement.repository;

import com.crimemanagement.model.Crime;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CrimeRepository extends MongoRepository<Crime, String> {
    
    List<Crime> findByCrimeType(String crimeType);
    
    List<Crime> findByLocation(String location);
    
    List<Crime> findByStatus(String status);
    
    @Query("{'crimeType': {$regex: ?0, $options: 'i'}}")
    List<Crime> findByCrimeTypeContainingIgnoreCase(String crimeType);
    
    @Query("{'location': {$regex: ?0, $options: 'i'}}")
    List<Crime> findByLocationContainingIgnoreCase(String location);

    @Query("{'description': {$regex: ?0, $options: 'i'}}")
    List<Crime> findByDescriptionContainingIgnoreCase(String description); // New search method
    
    List<Crime> findByReportedBy(String reportedBy);
}
