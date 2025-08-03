package com.crimemanagement.service;

import com.crimemanagement.model.User;
import com.crimemanagement.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    public Map<String, Object> authenticateUser(String username, String password) {
        Map<String, Object> response = new HashMap<>();
        
        Optional<User> userOpt = userRepository.findByUsername(username);
        
        if (userOpt.isPresent() && userOpt.get().getPassword().equals(password)) {
            User user = userOpt.get();
            response.put("success", true);
            response.put("user", user);
            response.put("role", user.getRole());
        } else {
            response.put("success", false);
            response.put("message", "Invalid credentials");
        }
        
        return response;
    }
    
    public User registerUser(User user) {
        if (!userRepository.existsByUsername(user.getUsername()) && 
            !userRepository.existsByEmail(user.getEmail())) {
            return userRepository.save(user);
        }
        return null;
    }
    
    public User getUserById(String id) {
        return userRepository.findById(id).orElse(null);
    }
}
