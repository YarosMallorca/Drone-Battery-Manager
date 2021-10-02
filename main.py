from kivy.config import Config

Config.set('graphics', 'window_state', 'visible')
Config.set('graphics', 'fullscreen', False)

Config.set('graphics', 'width', 459)
Config.set('graphics', 'height', 994)
Config.set('graphics', 'position', 'auto')

from kivymd.app import MDApp
from kivy.lang.builder import Builder
from kivymd.toast import toast


class LiPoManagerApp(MDApp):
    def build(self):
        self.cycles_list = open("config.txt", "r").read().split(",") # Load cycles to list as str
        self.cycles_list = [int(i) for i in self.cycles_list] # Convert str to int in each
        
        return Builder.load_file("ui.kv") # Load .kv file to load UI
    
    def modify_cycles(self, action):
        # ---- Battery 1 ----
        if action == "1+":
            self.cycles_list[0] += 1
            self.root.ids.bat1cycles.text = str(self.cycles_list[0])
            
        elif action == "1-":
            if self.cycles_list[0] > 0:
                self.cycles_list[0] -= 1
                self.root.ids.bat1cycles.text = str(self.cycles_list[0])


        # ---- Battery 2 ----
        if action == "2+":
            self.cycles_list[1] += 1
            self.root.ids.bat2cycles.text = str(self.cycles_list[1])

        elif action == "2-":
            if self.cycles_list[1] > 0:
                self.cycles_list[1] -= 1
                self.root.ids.bat2cycles.text = str(self.cycles_list[1])


        # ---- Battery 3 ----
        if action == "3+":
            self.cycles_list[2] += 1
            self.root.ids.bat3cycles.text = str(self.cycles_list[2])

        elif action == "3-":
            if self.cycles_list[2] > 0:
                self.cycles_list[2] -= 1
                self.root.ids.bat3cycles.text = str(self.cycles_list[2])

                
        # ---- Save Settings ----
        config_file = open("config.txt", "w")
        config_file.write(str(self.cycles_list[0]) + "," + str(self.cycles_list[1]) + "," + str(self.cycles_list[2]))
        config_file.close()
        self.calculate_recommended() # Recalculate and Update Recommended Battery Label
    
    def on_start(self):
        self.root.ids.bat1cycles.text = str(self.cycles_list[0])
        self.root.ids.bat2cycles.text = str(self.cycles_list[1])
        self.root.ids.bat3cycles.text = str(self.cycles_list[2])
        self.calculate_recommended() # Display current value of recommended battery
    
    def calculate_recommended(self):
        min_index = self.cycles_list.index(min(self.cycles_list)) # Finds the index of the least used battery
        self.root.ids.recommendedbattery.text = "Recommended Battery to Fly: " + str(min_index + 1)
        
    
    
LiPoManagerApp().run()