require 'gosu'
module ZOrder 
    BACKGROUND,MIDDLE,PLAYER,UI = *0..3
end
WIDTH = 1000
HEIGHT = 700
LUCKYTIME = 20000
class Helicopter
    attr_accessor :x, :y, :score, :image, :lives, :full_health, :half_health, :least_health, :zero_health, :equipped_DoubleBullet, :equipped_TripleBullet
    def initialize(x,y)
        @score = 0
        @image = Gosu::Image.new("images/plane.png")
        @x = x
        @y = y
        @lives = 3
        @full_health = Gosu::Image.new("images/fullhealth.png")
        @half_health = Gosu::Image.new("images/halfhealth.png")
        @least_health = Gosu::Image.new("images/leasthealth.png")
        @zero_health = Gosu::Image.new("images/zerohealth.png")
        @equipped_DoubleBullet = false # Haven't been equipped with double-bullet gun
        @equipped_TripleBullet = false
    end
end

class Asteroid
    attr_accessor :image, :x, :y, :speed
    def initialize
        @image = Gosu::Image.new("images/rock.png")
        @x = rand(0..WIDTH- @image.width)
        @y = 0
        @speed = rand(2..5)
    end
end

class SingleBullet
    attr_accessor :image, :x, :y
    def initialize(x,y)
        @image =  Gosu::Image.new("images/Bullet.png")
        @x = x
        @y = y
    end
end

class DoubleBullet
    attr_accessor :s1, :s2
    def initialize(x,y)
        @s1 = SingleBullet.new(x+10,y)
        @s2 = SingleBullet.new(x-10,y)
    end
end

class TripleBullet
    attr_accessor :tripleBulletArray, :s1, :s2, :s3
    def initialize(x,y)
        @s1 = SingleBullet.new(x+7,y)            
        @s2 = SingleBullet.new(x,y)                         
        @s3 = SingleBullet.new(x,y)
        @tripleBulletArray = [@s1,@s2,@s3] #tripleBulletArray attribute will contain 3 different single bullet
    end
end

class WhiteStar
    attr_accessor :image, :x, :y, :appear_time 
    def initialize
        @image = Gosu::Image.new("images/lucky_star.png")
        @x = rand(0..(WIDTH - @image.width))
        @y = rand(0..(HEIGHT - @image.height))
        @appear_time = 0 #Set the appearing time of the white Star (counted when it appears)
    end
end

class YellowStar
    attr_accessor :image, :x, :y, :appear_time 
    def initialize
        @image = Gosu::Image.new("images/yellowStar.png")
        @x = rand(0..(WIDTH - @image.width))
        @y = rand(0..(HEIGHT - @image.height))
        @appear_time = 0 #Set the appearing time of the yellow Star (counted when it appears)
    end
end
 
class Explosion
    attr_accessor :images, :sound, :current_index, :finished, :exploded_time
    def initialize
        @images = Gosu::Image.load_tiles("images/explosion.png",32,32)
        @sound = Gosu::Sample.new("images/explosion_sound.wav")
        @current_index =0
        @finished = false
        @exploded_time = 0
    end
end

class SingleMonsterBullet 
    attr_accessor :x, :y, :image
    def initialize(x,y)
        @image = Gosu::Image.new("images/monster_bullet.png")
        @x = x 
        @y = y 
    end 
end 

class MonsterBullet 
    attr_accessor :image, :s1, :s2, :s3, :s4, :s5, :s6, :monster_bullet_array, :shooting_time
    def initialize(x,y)
        @s1 = SingleMonsterBullet.new(x+25,y-10)
        @s2 = SingleMonsterBullet.new(x+15,y-5)
        @s3 = SingleMonsterBullet.new(x+5,y)
        @s4 = SingleMonsterBullet.new(x-5,y)
        @s5 = SingleMonsterBullet.new(x-15,y-5)
        @s6 = SingleMonsterBullet.new(x-25,y-10)
        @shooting_time = 0
        @monster_bullet_array = [@s1,@s2,@s3,@s4,@s5,@s6]
    end 
end

class Monster
    attr_accessor :images, :x, :y, :appeared, :health, :song, :blood_bar, :remaining_percent, :current_index
    def initialize(x,y)
        @images = Gosu::Image.load_tiles("images/octopus.png",96,128)
        @current_index = 6 #Current index of the image in tiles array
        @x = x 
        @y = y 
        @appeared = false
        @health = 100
        @song = Gosu::Song.new("images/Multiny.mp3")
        @blood_bar = Gosu::Image.new("images/blood_red_bar.png")
        @remaining_percent = 1.0 #The remaining percent of monster's blood bar
    end 
end 

class AlertMessage 
    attr_accessor :message, :x, :y, :displayed, :sound, :display_time, :alert_sound, :alert_time
    def initialize(x,y)
        @message = "BE CAREFUL!!!"
        @x = x 
        @y = y 
        @displayed = false
        @alert_sound = Gosu::Song. new("images/AlertSound.wav")
        @display_time = 0
        @alert_time = 0 
    end
end


class SpaceShooterGame < Gosu::Window
    def initialize
        super WIDTH,HEIGHT,false
        self.caption = "Space Shooter Game"
        #Instantiated a helicopter
        @helicopter = Helicopter.new(WIDTH/2,HEIGHT - 70)
        #Create an Asteroids array
        @asteroids = Array.new() #limit the number of bullets shot
        #Create an array for explosion sprites
        @explosions = Array.new()
        #Create a single bullet array
        @singleBullets = Array.new()
        #Create a double bullets array
        @doubleBullets = Array.new()
        #Create a triple bullets array
        @tripleBullets = Array.new()
        #Create a lucky white star (the helicopter will be equipped with double-bullet gun if it eat the white star)
        @whiteStars = Array.new()
        #Create a lucky yellow star (the helicopter will be equipped with triple-bullets gun if it eat the yellow star)
        @yellowStars = Array.new()
        @appeared_white_star = false #The white star hasnt appeared
        @appeared_yellow_star = false # The yellow star hasnt appeared
        @monster = Monster.new(WIDTH/2, -150) #Initialize monster
        @monster_bullets = Array.new() #Initialize monster bullet
        @horizontal_move = 3 #The horizontal move of the octopus
        #Background image
        @background = Gosu::Image.new("images/backgroundSpace.png")
        @goToMenu = true
        @menu = Gosu::Image.new("images/menu.png")
        @option_background = Gosu::Image.new("images/bg_1_1.png")
        @music = Gosu::Song.new("images/Popsicle - LFZ.mp3")
        @winning_music = Gosu::Song.new("images/title.mp3")
        @shot = Gosu::Sample.new("images/BangShort.ogg")
        @alert_message = AlertMessage.new(WIDTH/2-200,0) #Create an alert message before the monster appear
        @font = Gosu::Font.new(20)
        @startGame = false
        @option = false
        @won = false 
        @endgameTime = 0
        @start_time = 0 #Start_time is the period of time when the player is at the menu or option interface
        @round_time = 0 #Round_Time is actually the time from when the game is started until the game is finished
        @return_menu_color = Gosu::Color::RED
    end

    def move_left helicopter
        helicopter.x -= 5
        if (helicopter.x <=0)
            helicopter.x =0
        end
    end
    
    #move right function
    def move_right helicopter
        helicopter.x += 5
        if (helicopter.x >= WIDTH-65)
            helicopter.x = WIDTH-65
        end
    end
    #move up fuction
    def move_up helicopter
        helicopter.y -= 5
        if (helicopter.y <= 0)
            helicopter.y = 0
        end
    end
    #move down function
    def move_down helicopter
        helicopter.y += 5
        if (helicopter.y >= HEIGHT-65)
            helicopter.y = HEIGHT-65
        end
    end
    #Generate asteroids
    def generate_asteroids
        if @round_time < 10000
            if (rand(100) == 1)
                @asteroids.push(Asteroid.new())
            end
        elsif @round_time >= 10000 && @round_time < 20000
            if (rand(100) < 3)
                @asteroids.push(Asteroid.new())
            end
        else
            if (rand(100) < 5)
                @asteroids.push(Asteroid.new())
            end
        end
    end

    #movement of the asteroid
    def move_asteroid asteroid
        asteroid.y += asteroid.speed
    end
    #Control the movement all of type of bullets
    def move_bullets
        @singleBullets.each {|bullet| move_bullet(bullet) }
        @doubleBullets.each do |double_bullet|
            move_bullet (double_bullet.s1)
            move_bullet (double_bullet.s2)
        end
        @tripleBullets.each do |triple_bullet|
            move_triple_bullet (triple_bullet.tripleBulletArray)
        end
    end
     
    def move_bullet bullet
        bullet.y -= 3
    end 
    
    def move_triple_bullet tripleBulletArray
        if (tripleBulletArray[0] != 'null')
            tripleBulletArray[0].y -= 3
        end
        if (tripleBulletArray[1] != 'null' )
            tripleBulletArray[1].x += 10
            tripleBulletArray[1].y -= 3
        end
        if (tripleBulletArray[2] != 'null')
            tripleBulletArray[2].x -= 10
            tripleBulletArray[2].y -= 3
        end
    end

    def move_helicopter
        if button_down? Gosu::KB_LEFT
            move_left(@helicopter)
        end
        if button_down? Gosu::KB_RIGHT
            move_right(@helicopter)
        end
        if button_down? Gosu::KB_UP
            move_up(@helicopter)
        end
        if button_down? Gosu::KB_DOWN
            move_down(@helicopter)
        end
    end

    def helicopter_is_colliding? #Check if the helicopter is collided with asteroids or not
        @asteroids.any? {|asteroid| collide?(asteroid,@helicopter)}
    end

    def collide? (asteroid,helicopter) 
        if Gosu::distance(asteroid.x, asteroid.y, helicopter.x, helicopter.y) < 60
            @explosions.push(Explosion.new()) #If the asteroid is collided with the helicopter, then the explosions array will create an explosion object
            @music.pause
            @explosions.each {|explosion| explosion.sound.play()}
            @helicopter.lives -=1
            @asteroids.reject! do |asteroid| #Then the asteroid which is collided will be removed
                if Gosu::distance(asteroid.x, asteroid.y, helicopter.x, helicopter.y) < 60 
                    true
                end
            end
            return true
        end
        false
    end

    def destroy_asteroid_by_single? #Single is single bullet (check whether the single bullet is shooting an asteroid)
        bullet_index = 0
        while (bullet_index < @singleBullets.length)
            asteroid_index = 0
            while (asteroid_index < @asteroids.length)
                if (destroy_asteroid?(@singleBullets[bullet_index], @asteroids[asteroid_index]))
                    @singleBullets.delete_at(bullet_index) #If collided, that single bullet as well as asteroid will be deleted out of an array
                    @asteroids.delete_at(asteroid_index) 
                    break
                end
                asteroid_index +=1
            end
            bullet_index +=1
        end
    end

    def destroy_asteroid_by_double? #double is double bullet (check whether the double-bullet shot is colliding with an asteroid)
        double_bullet_index = 0
        while (double_bullet_index < @doubleBullets.length)
            asteroid_index = 0
            while (asteroid_index < @asteroids.length)
                if (destroy_asteroid?(@doubleBullets[double_bullet_index].s1, @asteroids[asteroid_index]) || destroy_asteroid?(@doubleBullets[double_bullet_index].s2, @asteroids[asteroid_index]) )
                    @doubleBullets.delete_at(double_bullet_index) #Like the single bullet above
                    @asteroids.delete_at(asteroid_index)
                    break
                end
                asteroid_index +=1
            end
            double_bullet_index +=1
        end
    end

    def destroy_asteroid_by_triple? #check whether the triple-bullet shot is colliding with an asteroid
        triple_bullet_index = 0 
        while (triple_bullet_index < @tripleBullets.length)
            triple_bullet_array = @tripleBullets[triple_bullet_index].tripleBulletArray #Assign the array with the new name for short
            asteroid_index = 0
            while (asteroid_index < @asteroids.length)
                if ( (triple_bullet_array[0] != 'null') &&  destroy_asteroid?( triple_bullet_array[0], @asteroids[asteroid_index]))
                    triple_bullet_array[0] = 'null' #If the first single bullet inside an array of triple bullet shot an asteroid, it will be removed (set to be 'null') out of the array
                    @asteroids.delete_at(asteroid_index)
                elsif ( (triple_bullet_array[1] != 'null') && destroy_asteroid?( triple_bullet_array[1], @asteroids[asteroid_index]))
                    triple_bullet_array[1] = 'null' #If the second single bullet inside an array of triple bullet shot an asteroid, it will be removed (set to be 'null') out of the array
                    @asteroids.delete_at(asteroid_index)
                elsif ( (triple_bullet_array[2] != 'null') && destroy_asteroid?( triple_bullet_array[2], @asteroids[asteroid_index]))
                    triple_bullet_array[2] = 'null' #If the third single bullet inside an array of triple bullet shot an asteroid, it will be removed (set to be 'null') out of the array
                    @asteroids.delete_at(asteroid_index)
                end
                asteroid_index +=1
            end
            triple_bullet_index +=1
        end
    end

    def destroy_asteroid? (bullet,asteroid) #Check collision between a bullet and an asteroid
        if Gosu::distance(bullet.x,bullet.y, asteroid.x, asteroid.y) < 50
            @shot.play(volume = 0.2, speed = 1, looping = false)
            @helicopter.score +=1 #If an asteroid has been destroyed, the helicopter score will increase by 1
            return true
        end
        false
    end

    def generate_lucky_stars
        if (@round_time > LUCKYTIME) && !@helicopter.equipped_DoubleBullet #After 20 secs, if the helicopter has yet been equipped with double-bullet gun, the white star may randomly appear
            if rand(100) == 3 && !@appeared_white_star #If the white star is not appearing on the screen, then it may be created (I dont want to make multiple white stars exist simultaneously)
                @whiteStars << WhiteStar.new()
                @appeared_white_star = true
            end
        end

        if (@round_time > LUCKYTIME*1.5) && !@helicopter.equipped_TripleBullet #Same as white star but the game should start for more than 30 seconds
            if rand(100) == 3 && !@appeared_yellow_star
                @yellowStars << YellowStar.new()
                @appeared_yellow_star = true
            end
        end
    end

    def check_eat_stars? 
        if eat_white_star? #If the white star is 'eaten' by the helicopter
            @helicopter.equipped_DoubleBullet = true #then the helicopter can equipped with double-bullet gun
        end
        if eat_yellow_star? #If the yellow star is 'eaten' by the helicopter
            @helicopter.equipped_TripleBullet = true #then the helicopter can equipped with double-bullet gun
        end
    end

    def eat_white_star? #Check if the player "eat" the white star - which will enable helicopter to be equipped with 2x bullet gun
        @whiteStars.any? {|whiteStar| eaten_by?(whiteStar,@helicopter)}
    end

    def eat_yellow_star? #Check if the player "eat" the yellow star - which will enable helicopter to be equipped with 3x bullet gun
        @yellowStars.any? {|yellowStar| eaten_by?(yellowStar,@helicopter)}
    end

    def eaten_by? star,helicopter #Check whether helicopter collides with star
        if Gosu.distance(star.x,star.y, helicopter.x, helicopter.y) < 50
            @whiteStars.reject! do |whiteStar| #If there is a collision, the collided white star will be rejected
                if Gosu::distance(whiteStar.x, whiteStar.y, helicopter.x, helicopter.y) < 50
                    true
                end
            end
            @yellowStars.reject! do |yellowStar| #Same as above
                if Gosu::distance(yellowStar.x, yellowStar.y, helicopter.x, helicopter.y) < 50
                    true
                end
            end
            return true
        end
        false
    end

    def alert_message
        if @helicopter.score >= 50 && !@monster.appeared
            @music.stop
            @alert_message.displayed = true
            @alert_message.alert_sound.play(false) 
            @alert_message.alert_time += 1
            move_alert_message
            if (@alert_message.alert_time == 180) #When the alert message appear for 3 seconds, it will be deleted and the monster will appear
                @alert_message.alert_time = 0
                @alert_message.displayed = false
                @alert_message.y = 0
                @alert_message.alert_sound.stop
            end
        end
    end

    def move_alert_message 
        if (@alert_message.displayed)
            @alert_message.y += 3
            if (@alert_message.y >= HEIGHT/2 - 50)
                @alert_message.y = HEIGHT/2 - 50
            end
        end
    end

    def monster_can_appear? 
        if (@helicopter.score >= 50 && !@alert_message.displayed) ##If the score reach 50 and the alert message has already been displayed, the monster will appear
            @monster.appeared = true 
        end
    end

     #If monster.appeared =>
    def move_monster monster
        if (monster.y < 100)
            monster.y += 3
            monster.current_index = (Gosu.milliseconds/600)%3 + 6 #Set the current index for the monster image : e.g: If Gosu.millisecs/600 % 3 = 0 => Draw at 6th image ...
        else
            monster.x -= @horizontal_move
            if (monster.x <= 100)
                @horizontal_move *= -1
            end    
            if (monster.x >= 900)
                @horizontal_move *= -1
            end
            #Set the current index again!
            if (monster.x > 400 && monster.x < 600)
                monster.current_index = (Gosu.milliseconds/600)%3 + 6
            else 
                if (@horizontal_move < 0) #the octopus is going to right side
                    monster.current_index = (Gosu.milliseconds/600)%3 + 3 
                else  #The octopus is going to the left side
                    monster.current_index = (Gosu.milliseconds/600)%3 + 9
                end
            end
        end 
    end

    def add_monster_bullets()
        if @monster.y >= 100
            if (@monster_bullets.length == 0)
                @monster_bullets << MonsterBullet.new(@monster.x,@monster.y)
            else 
                if (@monster_bullets[-1].shooting_time == 60) #when the latest bullet has been shot for 1sec, the next one will be released 
                    @monster_bullets << MonsterBullet.new(@monster.x, @monster.y)
                end
            end
            @monster_bullets.each do |monster_bullet|
                monster_bullet.shooting_time += 1
            end

            @monster_bullets.each {|monster_bullet| move_monster_bullet(monster_bullet.monster_bullet_array)}
        end
    end


    def move_monster_bullet(monster_bullet_array)
        if monster_bullet_array[0] != 'null'
            monster_bullet_array[0].x += 5
            monster_bullet_array[0].y += 5
        end 
        if monster_bullet_array[1] != 'null'
            monster_bullet_array[1].x += 3
            monster_bullet_array[1].y += 5
        end
        if monster_bullet_array[2] != 'null'
            monster_bullet_array[2].x += 1
            monster_bullet_array[2].y += 5
        end 
        if monster_bullet_array[3] != 'null'
            monster_bullet_array[3].x -= 1
            monster_bullet_array[3].y += 5
        end
        if monster_bullet_array[4] != 'null'
            monster_bullet_array[4].x -= 3
            monster_bullet_array[4].y += 5
        end
        if monster_bullet_array[5] != 'null'
            monster_bullet_array[5].x -= 5
            monster_bullet_array[5].y += 5
        end
    end

    def remove_monster_bullets 
        @monster_bullets.reject! do |monster_bullet|
            if monster_bullet.shooting_time == 120
                true
            end
        end
    end

    def collide_monster_bullet? (monster_bullet_array) #Check if the helicopter is collided with the octopus's bullets
        monster_bullet_array.each do |bullet|
            if (bullet != 'null' && Gosu::distance(bullet.x, bullet.y, @helicopter.x, @helicopter.y) < 50)
                @explosions.push(Explosion.new())
                @explosions.each {|explosion| explosion.sound.play()}
                @helicopter.lives -= 1
                null_index = monster_bullet_array.find_index(bullet) # try to find the index of the colliding bullet
                monster_bullet_array[null_index] = 'null' #Then set that bullet to be null
            end
        end
    end 

    def decrease_monster_health
        if (@monster.y >= 100)
            @monster.health -= 2
        end
    end

    def shoot_monster_by_single? #Check whether the player's shoot collides with the monster
        @singleBullets.reject! do |single_bullet| 
            if Gosu::distance(single_bullet.x, single_bullet.y, @monster.x, @monster.y) < 150
                decrease_monster_health()
                true
            end
        end
    end

    def shoot_monster_by_double?
        @doubleBullets.reject! do |double_bullet| 
            if Gosu::distance(double_bullet.s1.x, double_bullet.s1.y, @monster.x, @monster.y) < 150
                decrease_monster_health()
                decrease_monster_health()
                true
            end
        end
    end
    #
    def shoot_monster_by_triple?
        @tripleBullets.each do |triple_bullet| 
            if Gosu::distance(triple_bullet.s1.x, triple_bullet.s1.y, @monster.x, @monster.y) < 150
                if (triple_bullet.tripleBulletArray[0] != 'null')
                    decrease_monster_health()
                end
                triple_bullet.tripleBulletArray[0] = 'null'
            elsif Gosu::distance(triple_bullet.s2.x, triple_bullet.s2.y, @monster.x, @monster.y) < 150
                if (triple_bullet.tripleBulletArray[1] != 'null')
                    decrease_monster_health()
                end
                triple_bullet.tripleBulletArray[1] = 'null'
            elsif Gosu::distance(triple_bullet.s3.x, triple_bullet.s3.y, @monster.x, @monster.y) < 150
                if (triple_bullet.tripleBulletArray[2] != 'null')
                    decrease_monster_health()
                end
                triple_bullet.tripleBulletArray[2] = 'null'
            end
        end
    end

    def button_up(id)
        case id
        when Gosu::MsLeft
            if !@option #Check if the player is at the option or not
                if startGame?(mouse_x,mouse_y) #Check if clicking on the start button
                    @startGame = true 
                end
                if goToOption?(mouse_x,mouse_y) #Or whether he clicks on option button 
                    @startGame = false
                    @option = true
                end
            end
            if @option && out_option?(mouse_x,mouse_y) #Check if the player is currently at the option menu and clicks on "Return Menu" button
                @option = false
            end
        when Gosu::KB_SPACE 
            if (@singleBullets.length < 8) #If the number of current bullets displayed on the screen = 7, helicopter cant shot the single bullets
                @singleBullets << SingleBullet.new(@helicopter.x + 15, @helicopter.y)
            end
        when Gosu::KbLeftAlt
            if @doubleBullets.length < 6 && @helicopter.equipped_DoubleBullet #Check if the helicopter has been equipped with double bullet gun
                @doubleBullets << DoubleBullet.new(@helicopter.x + 15, @helicopter.y)
            end
        when Gosu::KbRightAlt
            if @tripleBullets.length < 4 && @helicopter.equipped_TripleBullet #Check if the helicopter has been equipped with triple bullet gun
                @tripleBullets << TripleBullet.new(@helicopter.x , @helicopter.y )
            end
        end
    end

    def startGame?(mouse_x, mouse_y)
        if mouse_x < 427 || mouse_x > 605
            return false
        end
        if mouse_y < 264 || mouse_y > 320
            return false
        end
        true
    end

    def goToOption? (mouse_x,mouse_y)
        if mouse_x < 427 || mouse_x > 605
            return false
        end
        if (mouse_y <361) || (mouse_y > 417)
            return false
        end
        true
    end
    
    def out_option?(mouse_x,mouse_y)
        if mouse_x < 50 || mouse_x > 200
            return false
        end
        if mouse_y < 630
            return false
        end
        true
    end

    def endgame? #Check if end game
        if @helicopter.lives == 0 || @helicopter.score == -10
            remove_all_objects
            return true
        end
        if won?()
            @won = true
            remove_all_objects
            return true
        end
        false
    end

    def won?
        if @helicopter.score >= 50
            if @monster.health <= 0
                @monster.appeared = false
                return true 
            end 
            false
        end
    end

    def return_to_menu?
        @endgameTime +=1 
        if (@endgameTime == 240) #If @endgame has occured for 4 seconds, it will return to menu
            @monster.song.stop
            @music.stop
            @goToMenu = true
            @startGame = false
            @endgameTime = 0
        end
    end

    def reset_game
        @helicopter.lives = 3
        @helicopter.score = 0
        @helicopter.x = WIDTH/2
        @helicopter.y = HEIGHT - 100
        @appeared_white_star = false
        @appeared_yellow_star = false
        @helicopter.equipped_DoubleBullet = false
        @helicopter.equipped_TripleBullet = false
        @monster.appeared = false
        @monster.x = WIDTH/2
        @monster.y = -30
        @monster.health = 100
    end

    def remove_asteroids
        @asteroids.reject! do |asteroid|
            if asteroid.y > HEIGHT
                @helicopter.score -=1
                true
            else
                false
            end
        end
    end
            
    def remove_explosions
        @explosions.reject! do |explosion|
            if explosion.finished
                true
            else
                false
            end
        end
    end

    def remove_bullets
        @singleBullets.reject! do |bullet| 
            if (bullet.y < 0)
                true
            else 
                false
            end
        end
        @doubleBullets.reject! do |doubleBullet|
            if (doubleBullet.s1.y <0) #s1 and s2 are at the same height, so just need to check whether s1 is out of the screen or not
                true
            else
                false
            end
        end
        #When removing triple-bullet object which contains 3 single bullets inside. Which single bullet take the longest time to go out of the screen will be prioritized to be checked
        @tripleBullets.each do |tripleBullet|
            tripleBulletArray = tripleBullet.tripleBulletArray #Instead of writing like tripleBullet.tripleBulletArray, I call it with the new name for short
            #When rejecting the triple-bullet object, the center bullet (which goes up straightly) will be prioritized to be checked
            if (tripleBulletArray[0]!='null' && tripleBulletArray[0].y <0) #If the center bullet hasnt collided with the asteroid, and if it goes out of the screen, then I the two others (which move diagonally) have already out of screen before
                @tripleBullets.delete(tripleBullet)
            elsif (tripleBulletArray[0] == 'null') 
                #If the center bullet has collided, we will check the two others moving diagonally. Which one take more time to go out of the screen will be checked
                if (@helicopter.x < WIDTH/2) #If the helicopter is at the left hand side of the screen, we will check the one that goes to the right
                    if (tripleBulletArray[1]!='null' && tripleBulletArray[1].x >WIDTH) #If that right one hasn't collided and it has gone out of the screen's width, then that triple bullet object will be deleted
                        @tripleBullets.delete(tripleBullet)
                    elsif (tripleBulletArray[1] == 'null') #How about if the right one is null?
                        if (tripleBulletArray[2]!='null' && tripleBulletArray[2].x <0) #We then check the remaining one!
                            @tripleBullets.delete(tripleBullet)
                        end
                    end
                else #If the helicopter is at the right hand side, we will do the same steps as above but in this case we'll check the left one first
                    if (tripleBulletArray[2]!='null' && tripleBulletArray[2].x <0)
                        @tripleBullets.delete(tripleBullet)
                    elsif (tripleBulletArray[2] == 'null')
                        if (tripleBulletArray[1]!='null' && tripleBulletArray[1].x >WIDTH)
                            @tripleBullets.delete(tripleBullet)
                        end
                    end
                end
            end
            if (tripleBulletArray[0] == 'null' && tripleBulletArray[1] == 'null' && tripleBulletArray[2] == 'null') #If all of 3 bullets inside tripleBullet object have collided, then that triple-bullet object will be removed
                @tripleBullets.delete(tripleBullet)
            end
        end
    end

    def remove_luckyStars #Remove the white and yellow Star after these appeared 240 frames (4 seconds)    
        @whiteStars.each {|white_star| remove_white_star(white_star)}
        @yellowStars.each {|yellow_star| remove_yellow_star(yellow_star)}
    end

    def remove_white_star white_star 
        if @appeared_white_star #If the white star is appearing, then the appear time of that star will be increased by 1 each frame
            white_star.appear_time +=1     
        end
        @whiteStars.reject! do |white_star|
            if white_star.appear_time == 240 #When the appear time reach 240, the white star will disappear.
                @appeared_white_star = false
                true
            end
        end
    end

    def remove_yellow_star yellow_star
        if @appeared_yellow_star 
            yellow_star.appear_time +=1
        end
        @yellowStars.reject! do |yellowStar|
            if yellow_star.appear_time == 240
                @appeared_yellow_star = false
                true
            end
        end
    end

    def remove_all_objects #all objects will be removed if the game has ended
        @singleBullets.reject! do |bullet|
            true
        end
        @doubleBullets.reject! do |doubleBullet|
            true
        end
        @tripleBullets.reject! do |tripleBullet|
            true
        end
        @asteroids.reject! do |asteroid|
            true
        end
        @monster_bullets.reject! do |monster_bullet|
            true
        end
    end

    def remove_all_asteroids  #Remove all asteroids when the score reach 50
        @asteroids.reject! do |asteroid|
            if @helicopter.score >= 50
                true 
            end
        end
    end

    def update  
        if (@startGame && !endgame?) #If the game has not ended and if the player has started the game => All of the game settings will be displayed
            @goToMenu = false
            move_helicopter()
            if (@helicopter.score < 50)
                generate_asteroids()
            end
            @asteroids.each {|asteroid| move_asteroid(asteroid) }
            move_bullets()
            check_eat_stars?()
            @round_time = Gosu.milliseconds - @start_time #Calculate the round time (which is like a real time of the game, counted when the game is started, not when the program is run)
            generate_lucky_stars()
            destroy_asteroid_by_single? # Check whether the single-bullet is colliding with the asteroid
            destroy_asteroid_by_double? # Check whether the double-bullet is colliding with the asteroid
            destroy_asteroid_by_triple? #Check whether the triple-bullet is colliding with the asteroid
            if (!helicopter_is_colliding? && !@alert_message.displayed && !@monster.appeared)
                @music.play(false)
                @music.volume = 0.1
            end
            alert_message()
            monster_can_appear?() #Check if the monster can appear or not!
            if (@monster.appeared)
                @monster.song.play(false)
                @monster.song.volume = 0.1
                move_monster(@monster)
                add_monster_bullets()
                shoot_monster_by_single?()
                shoot_monster_by_double?()
                shoot_monster_by_triple?()
                @monster_bullets.each {|monster_bullet| collide_monster_bullet?(monster_bullet.monster_bullet_array)} #Check if the helicopter collided with monster's bullets
            end
        elsif endgame? #If the games has ended                                                       
            return_to_menu? #Check if the player has returned back to the menu or not
        end
        if @won && !@goToMenu
            @winning_music.play(false)
            @helicopter.y -= 5
            if @helicopter.y <0
                @helicopter.y = -60
            end
        end
        if @goToMenu
            @winning_music.stop
            @start_time = Gosu.milliseconds #The start time is calculated when the program is run until the game starts
            @won = false
            reset_game()
        end
        self.remove_asteroids
        self.remove_all_asteroids
        self.remove_explosions
        self.remove_bullets
        self.remove_luckyStars
        self.remove_monster_bullets
    end  

    def draw_helicopter helicopter
        helicopter.image.draw(helicopter.x,helicopter.y,ZOrder::PLAYER)
    end

    def draw_helicopter_blood_bar helicopter
        if (helicopter.lives == 3)
            helicopter.full_health.draw(WIDTH - 270,0,ZOrder::UI,scale_x=0.7,scale_y=0.7)
        elsif (helicopter.lives == 2)
            helicopter.half_health.draw(WIDTH - 270,0,ZOrder::UI,scale_x=0.7,scale_y=0.7)
        elsif (helicopter.lives == 1)
            helicopter.least_health.draw(WIDTH - 270,0,ZOrder::UI,scale_x=0.7,scale_y=0.7)
        else 
            helicopter.zero_health.draw(WIDTH - 270,0,ZOrder::UI,scale_x=0.7,scale_y=0.7)
        end
    end

    def draw_asteroid(asteroid)
        asteroid.image.draw(asteroid.x, asteroid.y, ZOrder::PLAYER,scale_x=0.2, scale_y=0.2)
    end

    def draw_explosion explosion
        if (explosion.exploded_time <= 10)
            explosion.current_index = 0
        elsif (explosion.exploded_time > 10 && explosion.exploded_time <= 20)
            explosion.current_index = 1
        elsif (explosion.exploded_time > 20 && explosion.exploded_time <= 30)
            explosion.current_index = 2
        elsif (explosion.exploded_time > 30 && explosion.exploded_time <= 40)
            explosion.current_index = 3
        elsif (explosion.exploded_time > 50 && explosion.exploded_time <= 60)
            explosion.current_index = 4
        elsif (explosion.exploded_time > 60 && explosion.exploded_time < 70)
            explosion.current_index = 5
        end
        if (explosion.exploded_time >= 0 && explosion.exploded_time < 70)
            explosion.exploded_time += 1
        elsif (explosion.exploded_time == 70)
            explosion.finished = true
        end
        current_img = explosion.images[explosion.current_index]
        current_img.draw(@helicopter.x,@helicopter.y, ZOrder::PLAYER ,scale_x=2.0,scale_x=2.0)
    end

    def draw_bullet bullet
        bullet.image.draw(bullet.x,bullet.y, ZOrder::PLAYER, scale_x = 0.2, scale_y = 0.2)
    end 

    def draw_triple_bullet tripleBulletArray
        tripleBulletArray.each do |bullet|
            if (bullet != 'null')
                draw_bullet (bullet)
            end
        end
    end

    def draw_whiteStar whiteStar
        whiteStar.image.draw(whiteStar.x, whiteStar.y, ZOrder::PLAYER, scale_x =0.3, scale_x =0.3)
    end
    
    def draw_yellowStar yellowStar
        yellowStar.image.draw(yellowStar.x, yellowStar.y, ZOrder::PLAYER, scale_x =0.3, scale_x =0.3)
    end

    def draw_monster monster
        if monster.appeared 
            current_img = monster.images[monster.current_index]
            current_img.draw(monster.x,monster.y, ZOrder::PLAYER, scale_x = 1.5, scale_y = 1.5)
        end
    end

    def calculate_remaining_percent monster
        monster.remaining_percent = ((monster.health)*1.0/100.0).to_f
    end

    def draw_monster_blood monster
        if monster.appeared 
            monster.blood_bar.draw(10,5, ZOrder::PLAYER, scale_x = 2.0, scale_y = 2.0)
            calculate_remaining_percent(monster)
            Gosu.draw_rect(24,20, monster.remaining_percent*562, 44 ,Gosu::Color::YELLOW, ZOrder::UI)
        end
    end

    def draw_monster_bullets monster_bullets
        monster_bullets.each {|monster_bullet| draw_monster_bullet(monster_bullet.monster_bullet_array)}
    end

    def draw_monster_bullet monster_bullet_array
        if monster_bullet_array[0] != 'null'
            monster_bullet_array[0].image.draw(monster_bullet_array[0].x,monster_bullet_array[0].y,ZOrder::PLAYER,scale_x = 0.2, scale_y = 0.2)
        end
        if monster_bullet_array[1] != 'null'
            monster_bullet_array[1].image.draw(monster_bullet_array[1].x,monster_bullet_array[1].y,ZOrder::PLAYER,scale_x = 0.2, scale_y = 0.2)
        end
        if monster_bullet_array[2] != 'null'
            monster_bullet_array[2].image.draw(monster_bullet_array[2].x,monster_bullet_array[2].y,ZOrder::PLAYER,scale_x = 0.2, scale_y = 0.2)
        end
        if monster_bullet_array[3] != 'null'
            monster_bullet_array[3].image.draw(monster_bullet_array[3].x,monster_bullet_array[3].y,ZOrder::PLAYER,scale_x = 0.2, scale_y = 0.2)
        end
        if monster_bullet_array[4] != 'null'
            monster_bullet_array[4].image.draw(monster_bullet_array[4].x,monster_bullet_array[4].y,ZOrder::PLAYER,scale_x = 0.2, scale_y = 0.2)
        end
        if monster_bullet_array[5] != 'null'
            monster_bullet_array[5].image.draw(monster_bullet_array[5].x,monster_bullet_array[5].y,ZOrder::PLAYER,scale_x = 0.2, scale_y = 0.2)
        end
    end

    def write_options
        @font.draw_text("Use Spacebar to shoot bullets", WIDTH/2 - 400, HEIGHT/2 - 100, ZOrder::MIDDLE, scale_x = 1.0, scale_y = 1.0, Gosu::Color.argb(0xff_00ffff))
        @font.draw_text("There would be a random time that you can see the Lucky White Star and the Lucky Yellow Star!
When the helicopter eats the White Star, use the Left Atl keyboard to use double-bullet gun!
And when the helicopter eats the Yellow Star, use the Right Atl keyboard to use triple-bullet gun!
Try to destroy the asteroids and kill the MONSTER by shooting the bullets!!!!
You will get 1 score after destroying an asteroid and when getting 50 scores, a monster will appear! 
If you kill the monster, you will win!
Howerver, if the asteroids fall out of the screen, you will be deducted 1 mark
Remember that the helicopter just have 3 lives, and if your mark is -10, you will lose!!
NOTE: You can only shoot 7 single-bullet, 5 double-bullet and 3 triple-bullet for maximum per time!", WIDTH/2 - 400, HEIGHT/2 - 80, ZOrder::MIDDLE, scale_x = 1.0, scale_y = 1.0, Gosu::Color.argb(0xff_00ffff))
    end

    def draw 
        if @startGame #If the player starts the game (click on 'start game' button), all of the objects in the game will be drawn
            @background.draw(0,0,ZOrder::BACKGROUND, scale_x=1.0, scale_y=1.0)
            @asteroids.each {|asteroid| draw_asteroid(asteroid)}
            draw_helicopter(@helicopter)
            @singleBullets.each {|bullet| draw_bullet(bullet)}
            @doubleBullets.each do |double_bullet|
                draw_bullet(double_bullet.s1)
                draw_bullet(double_bullet.s2)
            end
            @tripleBullets.each {|triple_bullet| draw_triple_bullet(triple_bullet.tripleBulletArray)}
            @whiteStars.each {|whiteStar| draw_whiteStar(whiteStar)}
            @yellowStars.each {|yellowStar| draw_yellowStar(yellowStar)}
            @explosions.each {|explosion| draw_explosion(explosion)} 
            draw_monster(@monster)
            draw_monster_blood(@monster)
            draw_monster_bullets(@monster_bullets)
            if @helicopter.equipped_DoubleBullet #Display the message to inform that the player can shot double bullet gun
                @font.draw_text("Now you can use double-bullet gun by pressing the Left Alt", 27,10,ZOrder::MIDDLE,scale_x = 1.0, scale_y = 1.0, Gosu::Color::WHITE)
            end
            if @helicopter.equipped_TripleBullet #Display the message to inform that the player can shot triple bullet gun
                @font.draw_text("Now you can use triple-bullet gun by pressing the Right Alt", 27,32,ZOrder::MIDDLE,scale_x = 1.0, scale_y = 1.0, Gosu::Color::WHITE)
            end
            draw_helicopter_blood_bar(@helicopter)
            @font.draw_text("You have #{@helicopter.score} scores", WIDTH - 200, HEIGHT - 50 , ZOrder::MIDDLE, scale_x = 1.0, scale_y = 1.0, Gosu::Color::WHITE)
            if (@alert_message.displayed) 
                @font.draw_text(@alert_message.message,@alert_message.x, @alert_message.y, ZOrder::MIDDLE, scale_x = 3.0, scale_y = 3.0, Gosu::Color::RED)
            end
            if (@helicopter.lives == 0 || @helicopter.score == -10) && !@goToMenu #If the player lost but the Menu interface hasnt been displayed, then there would be a "You lose" notice
                @font.draw_text("YOU LOSE", WIDTH/2 - 100, HEIGHT/2 - 20 , ZOrder::MIDDLE, scale_x = 3.0, scale_y = 3.0, Gosu::Color::RED)
            end
            if @won && !@goToMenu
                @font.draw_text("YOU WIN", WIDTH/2 - 100, HEIGHT/2 - 20 , ZOrder::MIDDLE, scale_x = 3.0, scale_y = 3.0, Gosu::Color::RED)
            end
        elsif @option #Draw option when the player go to the option menu
            @option_background.draw(0,0,ZOrder::BACKGROUND, scale_x=1.4, scale_y=1.2)
            write_options
            Gosu.draw_rect(50,HEIGHT-70, 150, 70,@return_menu_color, ZOrder::MIDDLE)
            if (out_option?(mouse_x,mouse_y))
                @return_menu_color = Gosu::Color::YELLOW
            else 
                @return_menu_color = Gosu::Color::RED
            end
            @font.draw_text("RETURN MENU",  60 , HEIGHT - 40 , ZOrder::PLAYER, scale_x = 1.0, scale_y = 1.0, Gosu::Color::WHITE)
        elsif @goToMenu
            @menu.draw(0,0,ZOrder::BACKGROUND,scale_x = 1.0, scale_y = 1.4)
        end
    end
end
window = SpaceShooterGame.new
window.show
## octopus tiles