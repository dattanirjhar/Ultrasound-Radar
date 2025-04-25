import processing.serial.*;
Serial myPort;
String angle = "";
String distance = "";
String data = "";
boolean firstContact = false;

// For sweep line animation
float sweepAngle;

// For object persistence and fade effect
final int MAX_POINTS = 100;
float[] pointAngles = new float[MAX_POINTS];
float[] pointDistances = new float[MAX_POINTS];
int[] pointAges = new int[MAX_POINTS];
int pointCount = 0;

// Color scheme
color backgroundColor = color(0, 20, 40);
color gridColor = color(0, 100, 130, 150);
color sweepColor = color(0, 255, 0, 150);
color pointColor = color(0, 255, 0);

void setup() {
  size(800, 600);
  background(backgroundColor);
  
  // Initialize points array
  for (int i = 0; i < MAX_POINTS; i++) {
    pointAges[i] = -1; // -1 means no point
  }
  
  // Print available serial ports
  printArray(Serial.list());
  
  // Initialize the serial port connection
  // Check if there are any available ports
  if (Serial.list().length > 0) {
    // Connect to the first available port
    // You might need to change the index (0) to match your Arduino port
    String portName = Serial.list()[0];
    myPort = new Serial(this, portName, 9600); // Assuming 9600 baud rate, adjust if needed
    myPort.bufferUntil('.');
  } else {
    println("No serial ports available. Please connect your Arduino.");
  }
}

void draw() {
  background(backgroundColor);
  
  // Move origin to bottom-center
  translate(width / 2, height - 50);
  
  // Draw radar background elements
  drawRadarBackground();
  
  // Draw the sweep line
  drawSweepLine();
  
  // Draw detected objects
  if (firstContact && myPort != null) {
    drawPointsWithFade();
  }
  
  // Add range indicators
  drawRangeLabels();
}

void drawRadarBackground() {
  // Outer arc
  noFill();
  stroke(gridColor);
  strokeWeight(2);
  arc(0, 0, 600, 600, PI, TWO_PI);
  
  // Range rings
  strokeWeight(1);
  for (int r = 100; r <= 500; r += 100) {
    stroke(gridColor);
    arc(0, 0, r * 2, r * 2, PI, TWO_PI);
  }
  
  // Angle lines
  for (int i = 0; i <= 180; i += 15) {
    float rad = radians(i);
    float x = cos(rad) * 600;
    float y = -sin(rad) * 600;
    stroke(gridColor, 100);
    line(0, 0, x, y);
    
    // Add angle labels (except at 90°)
    if (i % 30 == 0 && i != 90) {
      fill(gridColor);
      textAlign(CENTER);
      textSize(12);
      text(i + "°", cos(rad) * 320, -sin(rad) * 320);
    }
  }
}

void drawSweepLine() {
  // Get current angle from Arduino if available, or animate smoothly
  float targetAngle = angle.length() > 0 ? float(angle) : sweepAngle;
  sweepAngle = targetAngle;
  
  // Convert to radians for drawing
  float rad = radians(sweepAngle);
  
  // Draw sweep line
  stroke(sweepColor);
  strokeWeight(3);
  line(0, 0, cos(rad) * 300, -sin(rad) * 300);
  
  // Draw sweep arc effect (fading tail)
  noFill();
  for (int i = 0; i < 15; i++) {
    float tailAngle = rad - radians(i * 2);
    stroke(0, 255, 0, 150 - (i * 10));
    strokeWeight(2 - (i * 0.1));
    
    // Only draw if in valid range
    if (degrees(tailAngle) >= 0 && degrees(tailAngle) <= 180) {
      line(0, 0, cos(tailAngle) * 300, -sin(tailAngle) * 300);
    }
  }
  
  // Add a glowing effect at current position
  noStroke();
  fill(0, 255, 0, 50);
  ellipse(0, 0, 30, 30);
}

void drawPointsWithFade() {
  // Update point ages and remove old ones
  for (int i = 0; i < pointCount; i++) {
    if (pointAges[i] >= 0) {
      pointAges[i]++;
      
      // Remove points after they age out
      if (pointAges[i] > 180) {
        pointAges[i] = -1;
      }
    }
  }
  
  // Draw all active points
  for (int i = 0; i < pointCount; i++) {
    if (pointAges[i] >= 0) {
      float a = radians(pointAngles[i]);
      float d = pointDistances[i];
      
      if (d > 0 && d <= 600) {
        float x = cos(a) * d;
        float y = -sin(a) * d;
        
        // Calculate alpha based on age
        int alpha = max(255 - pointAges[i], 0);
        
        // Draw point with fading effect
        noStroke();
        fill(pointColor, alpha);
        ellipse(x, y, 8, 8);
        
        // Ripple effect for newer points
        if (pointAges[i] < 30) {
          noFill();
          stroke(pointColor, alpha * 0.7);
          ellipse(x, y, 20 + pointAges[i]/2, 20 + pointAges[i]/2);
        }
      }
    }
  }
}

void drawRangeLabels() {
  // Add range labels in meters
  fill(200);
  textAlign(LEFT);
  textSize(12);
  for (int r = 100; r <= 500; r += 100) {
    String label = (r/20) + "m";
    text(label, 5, -r + 5);
  }
  
  // Add title
  fill(255);
  textSize(18);
  textAlign(CENTER);
  text("Ultrasonic Radar Scanner", 0, -520);
}

void serialEvent(Serial myPort) {
  // Check if the port is actually connected
  if (myPort != null) {
    data = myPort.readStringUntil('.');
    if (data != null) {
      data = data.trim();
      
      int angleIndex = data.indexOf(",");
      int dotIndex = data.indexOf(".");
      
      if (angleIndex != -1 && dotIndex != -1) {
        angle = data.substring(0, angleIndex);
        distance = data.substring(angleIndex + 1, dotIndex);
        
        // Update sweeping angle for animation
        sweepAngle = float(angle);
        
        // Only add point if we have valid distance data
        float dist = float(distance);
        if (dist > 0 && dist <= 300) {
          // Scale distance for display
          dist = dist * 2;
          
          // Add new point to the array
          addNewPoint(float(angle), dist);
          
          firstContact = true;
        }
      }
    }
  }
}

void addNewPoint(float ang, float dist) {
  // Find an empty slot or reuse oldest point
  int oldestIndex = 0;
  int oldestAge = -1;
  
  int emptySlot = -1;
  for (int i = 0; i < MAX_POINTS; i++) {
    // Find empty slot
    if (pointAges[i] == -1) {
      emptySlot = i;
      break;
    }
    
    // Track oldest point
    if (oldestAge == -1 || pointAges[i] > oldestAge) {
      oldestAge = pointAges[i];
      oldestIndex = i;
    }
  }
  
  // Use empty slot if found, otherwise replace oldest
  int index = (emptySlot != -1) ? emptySlot : oldestIndex;
  
  // Store the new point
  pointAngles[index] = ang;
  pointDistances[index] = dist;
  pointAges[index] = 0;
  
  // Update point count if needed
  if (index >= pointCount) {
    pointCount = index + 1;
  }
}
