#!/usr/bin/env python3
"""
FDM Community Backend API Tests
Tests all API endpoints for the FDM Community site
"""

import requests
import sys
import json
from datetime import datetime, timedelta

class FDMBackendTester:
    def __init__(self, base_url="http://localhost:3001"):
        self.base_url = base_url
        self.admin_token = None
        self.tests_run = 0
        self.tests_passed = 0
        self.test_event_id = None

    def log_test(self, name, success, details=""):
        """Log test results"""
        self.tests_run += 1
        if success:
            self.tests_passed += 1
            print(f"✅ {name}")
        else:
            print(f"❌ {name} - {details}")
        
        if details and success:
            print(f"   📝 {details}")

    def run_test(self, name, method, endpoint, expected_status=200, data=None, headers=None):
        """Run a single API test"""
        url = f"{self.base_url}/{endpoint}"
        default_headers = {'Content-Type': 'application/json'}
        if headers:
            default_headers.update(headers)

        try:
            if method == 'GET':
                response = requests.get(url, headers=default_headers, timeout=10)
            elif method == 'POST':
                response = requests.post(url, json=data, headers=default_headers, timeout=10)
            elif method == 'PUT':
                response = requests.put(url, json=data, headers=default_headers, timeout=10)
            elif method == 'DELETE':
                response = requests.delete(url, headers=default_headers, timeout=10)

            success = response.status_code == expected_status
            
            if success:
                try:
                    response_data = response.json()
                    self.log_test(name, True, f"Status: {response.status_code}")
                    return True, response_data
                except:
                    self.log_test(name, True, f"Status: {response.status_code} (No JSON)")
                    return True, {}
            else:
                try:
                    error_data = response.json()
                    self.log_test(name, False, f"Expected {expected_status}, got {response.status_code} - {error_data}")
                except:
                    self.log_test(name, False, f"Expected {expected_status}, got {response.status_code}")
                return False, {}

        except requests.exceptions.ConnectionError:
            self.log_test(name, False, "Connection refused - Server not running?")
            return False, {}
        except requests.exceptions.Timeout:
            self.log_test(name, False, "Request timeout")
            return False, {}
        except Exception as e:
            self.log_test(name, False, f"Error: {str(e)}")
            return False, {}

    def test_discord_stats(self):
        """Test Discord stats endpoint"""
        print("\n🤖 Testing Discord Integration...")
        success, data = self.run_test(
            "Discord Stats API",
            "GET",
            "api/discord/stats"
        )
        
        if success and data:
            required_fields = ['memberCount', 'onlineCount', 'lastUpdate']
            missing_fields = [field for field in required_fields if field not in data]
            
            if not missing_fields:
                self.log_test("Discord Stats Structure", True, 
                            f"Members: {data['memberCount']}, Online: {data['onlineCount']}")
            else:
                self.log_test("Discord Stats Structure", False, 
                            f"Missing fields: {missing_fields}")

    def test_events_api(self):
        """Test events endpoints"""
        print("\n📅 Testing Events API...")
        
        # Get all events
        success, events = self.run_test(
            "Get Events",
            "GET",
            "api/events"
        )
        
        if success and events:
            self.log_test("Events Data Structure", True, f"Found {len(events)} events")
            
            # Check first event structure
            if events:
                event = events[0]
                required_fields = ['id', 'title', 'description', 'date', 'time']
                missing_fields = [field for field in required_fields if field not in event]
                
                if not missing_fields:
                    self.log_test("Event Structure", True, f"Event: {event['title']}")
                    self.test_event_id = event['id']  # Store for participation tests
                else:
                    self.log_test("Event Structure", False, f"Missing fields: {missing_fields}")

    def test_event_participation(self):
        """Test event participation"""
        print("\n👥 Testing Event Participation...")
        
        if not self.test_event_id:
            self.log_test("Event Participation", False, "No event ID available for testing")
            return

        test_username = f"test_user_{datetime.now().strftime('%H%M%S')}"
        
        # Test participation
        success, data = self.run_test(
            "Participate in Event",
            "POST",
            f"api/events/{self.test_event_id}/participate",
            data={"username": test_username}
        )
        
        if success and data.get('success'):
            self.log_test("Participation Success", True, 
                        f"User {test_username} participated: {data.get('participating')}")
            
            # Test unparticipation (toggle)
            success2, data2 = self.run_test(
                "Unparticipate from Event",
                "POST",
                f"api/events/{self.test_event_id}/participate",
                data={"username": test_username}
            )
            
            if success2 and data2.get('success'):
                self.log_test("Unparticipation Success", True, 
                            f"User {test_username} unparticipated: {not data2.get('participating')}")

        # Test invalid username
        self.run_test(
            "Invalid Username Participation",
            "POST",
            f"api/events/{self.test_event_id}/participate",
            expected_status=400,
            data={"username": "ab"}  # Too short
        )

    def test_event_download(self):
        """Test event download functionality"""
        print("\n📥 Testing Event Downloads...")
        
        if not self.test_event_id:
            self.log_test("Event Download", False, "No event ID available for testing")
            return

        test_username = f"test_downloader_{datetime.now().strftime('%H%M%S')}"
        
        # Test download
        success, data = self.run_test(
            "Download Event File",
            "POST",
            f"api/events/{self.test_event_id}/download",
            data={"username": test_username}
        )
        
        if success and data.get('success'):
            self.log_test("Download Success", True, 
                        f"Download recorded for {test_username}")

        # Test invalid username for download
        self.run_test(
            "Invalid Username Download",
            "POST",
            f"api/events/{self.test_event_id}/download",
            expected_status=400,
            data={"username": "xy"}  # Too short
        )

    def test_admin_authentication(self):
        """Test admin authentication"""
        print("\n🔐 Testing Admin Authentication...")
        
        # Test correct password
        success, data = self.run_test(
            "Admin Login (Correct)",
            "POST",
            "api/admin/login",
            data={"password": "fdm2024admin"}
        )
        
        if success and data.get('success'):
            self.admin_token = data.get('token')
            self.log_test("Admin Token Received", True, f"Token: {self.admin_token}")

        # Test incorrect password
        self.run_test(
            "Admin Login (Incorrect)",
            "POST",
            "api/admin/login",
            expected_status=401,
            data={"password": "wrongpassword"}
        )

    def test_admin_events_crud(self):
        """Test admin CRUD operations for events"""
        print("\n⚙️ Testing Admin Events CRUD...")
        
        if not self.admin_token:
            self.log_test("Admin CRUD", False, "No admin token available")
            return

        # Create new event
        future_date = (datetime.now() + timedelta(days=7)).strftime('%Y-%m-%d')
        new_event_data = {
            "title": "Test Event API",
            "description": "This is a test event created via API",
            "date": future_date,
            "time": "19:00",
            "category": "Gaming",
            "max_participants": 50,
            "has_download": True,
            "download_text": "Download Test Launcher"
        }
        
        success, data = self.run_test(
            "Create Event (Admin)",
            "POST",
            "api/admin/events",
            expected_status=200,
            data=new_event_data
        )
        
        created_event_id = None
        if success and data.get('success'):
            created_event_id = data.get('id')
            self.log_test("Event Creation", True, f"Created event ID: {created_event_id}")

        # Update event if created successfully
        if created_event_id:
            updated_event_data = new_event_data.copy()
            updated_event_data['title'] = "Updated Test Event API"
            updated_event_data['max_participants'] = 75
            
            success, data = self.run_test(
                "Update Event (Admin)",
                "PUT",
                f"api/admin/events/{created_event_id}",
                data=updated_event_data
            )

            # Delete the test event
            success, data = self.run_test(
                "Delete Event (Admin)",
                "DELETE",
                f"api/admin/events/{created_event_id}"
            )

    def test_admin_downloads_history(self):
        """Test admin downloads history"""
        print("\n📊 Testing Admin Downloads History...")
        
        success, data = self.run_test(
            "Get Downloads History",
            "GET",
            "api/admin/downloads"
        )
        
        if success:
            self.log_test("Downloads History", True, f"Found {len(data)} download records")

    def test_server_health(self):
        """Test basic server health"""
        print("\n🏥 Testing Server Health...")
        
        try:
            response = requests.get(f"{self.base_url}/", timeout=5)
            if response.status_code == 200:
                self.log_test("Server Health", True, "Main page accessible")
            else:
                self.log_test("Server Health", False, f"Status: {response.status_code}")
        except Exception as e:
            self.log_test("Server Health", False, f"Error: {str(e)}")

        # Test admin page
        try:
            response = requests.get(f"{self.base_url}/admin.html", timeout=5)
            if response.status_code == 200:
                self.log_test("Admin Page Health", True, "Admin page accessible")
            else:
                self.log_test("Admin Page Health", False, f"Status: {response.status_code}")
        except Exception as e:
            self.log_test("Admin Page Health", False, f"Error: {str(e)}")

    def run_all_tests(self):
        """Run all backend tests"""
        print("🚀 Starting FDM Community Backend Tests")
        print("=" * 50)
        
        # Test server health first
        self.test_server_health()
        
        # Test public APIs
        self.test_discord_stats()
        self.test_events_api()
        self.test_event_participation()
        self.test_event_download()
        
        # Test admin functionality
        self.test_admin_authentication()
        self.test_admin_events_crud()
        self.test_admin_downloads_history()
        
        # Print summary
        print("\n" + "=" * 50)
        print(f"📊 Test Results: {self.tests_passed}/{self.tests_run} passed")
        
        if self.tests_passed == self.tests_run:
            print("🎉 All tests passed!")
            return 0
        else:
            print(f"⚠️  {self.tests_run - self.tests_passed} tests failed")
            return 1

def main():
    tester = FDMBackendTester()
    return tester.run_all_tests()

if __name__ == "__main__":
    sys.exit(main())