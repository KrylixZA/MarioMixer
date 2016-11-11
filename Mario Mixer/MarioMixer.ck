//Keyboard listener global variables
Hid hi;
HidMsg msg;

//Sound Buffer & relative paths
SndBuf background => dac;
SndBuf buf => dac;
me.dir()+"/Sounds/" => string path;

//Declare file names
"mb_background.wav" => string marioBackground;
"mb_coin.wav" => string marioCoin;
"mb_die.wav" => string marioDie;
"mb_jump.wav" => string marioJump;
"mb_new.wav" => string newMario;
"mb_sc.wav" => string marioScore;
"mb_touch.wav" => string marioTouch;

//Generate paths to files
path+marioBackground => marioBackground;
path+marioCoin => marioCoin;
path+marioDie => marioDie;
path+marioJump => marioJump;
path+newMario => newMario;
path+marioScore => marioScore;
path+marioTouch => marioTouch;

//Initialize each sound's gain
0.5 => float marioBackgroundGain;
1.0 => float marioCoinGain;
1.0 => float marioDieGain;
1.0 => float marioJumpGain;
1.0 => float newMarioGain;
1.0 => float marioScoreGain;
1.0 => float marioTouchGain;

//Initialize background playback speed
1.0 => float marioBackgroundSpeed;

//Initialize player variables
1 => int isPlayerAlive;
0 => int playerScore;
100 => int playerHealth;

//Initialize the keyboard listener
fun void InitializeKeyboardListener(){
    0 => int device;
    if( me.args() ) me.arg(0) => Std.atoi => device;

    if(!hi.openKeyboard(device)) 
        me.exit();
}

//Play the Mario Background
fun void PlayMarioBackgroundMusic(){
    marioBackground => background.read;
    
    marioBackgroundGain => background.gain;
    marioBackgroundSpeed => background.rate;
    
    0 => background.pos;
    1 => background.loop;

    1::second => now;
}

//Play the Mario Jump sound
fun void PlayMarioJumpSound(){
    marioJump => buf.read;

    marioJumpGain => buf.gain;
    0 => buf.pos;

    100::ms => now;   
}

//Play the Mario Coin sound
fun void PlayMarioCoinSound(){
    marioCoin => buf.read;

    marioCoinGain => buf.gain;
    0 => buf.pos;

    1::second => now;
}

//Play the new Mario sound
fun void PlayNewMarioSound(){
    newMario => buf.read;

    newMarioGain => buf.gain;
    0 => buf.pos;

    2::second => now;
}

//Play the Mario dies sound
fun void PlayMarioDieSound(){
    marioDie => buf.read;

    marioDieGain => buf.gain;
    0 => buf.pos;

    2::second => now;
}

//Play the Mario score sound
fun void PlayMarioScoreSound(){
    marioScore => buf.read;
    
    marioScoreGain => buf.gain;
    0 => buf.pos;
    
    1::second => now;
}

//Play the Mario touuch sound
fun void PlayMarioTouchSound(){
    marioTouch => buf.read;
    
    marioTouchGain => buf.gain;
    0 => buf.pos;
    
    1::second => now;
}

fun void PlayerWins(){
    PlayMarioScoreSound();
    <<<"You have won!">>>;
    <<<"You collected ", playerScore, " coins.">>>;
    <<<"=====================================================">>>;
    me.exit();
}

fun void PlayerCollectedCoin(){
    playerScore ++;
    PlayMarioCoinSound();
    <<<"You have collected ", playerScore, " coin(s)">>>;
    PlayMarioScoreSound();
    
    marioBackgroundSpeed + 0.1 => marioBackgroundSpeed;
    marioBackgroundSpeed => background.rate;
    
    if (playerScore == 10){
        PlayerWins();
    }
}

fun void PlayerDied(){
    PlayMarioDieSound();
    <<<"Game over!">>>;
    <<<"You have died. You collected ", playerScore, " coins">>>;
    <<<"=====================================================">>>;
    me.exit();
}

fun void PlayerHitMushroom(){
    PlayMarioTouchSound();
    playerHealth - 10 => playerHealth;
    <<<"You have hit a mushroom!">>>;
    <<<"Your health is: ", playerHealth >>>;
    
    marioBackgroundSpeed - 0.1 => marioBackgroundSpeed;
    marioBackgroundSpeed => background.rate;
    
    if (playerHealth == 0){
        PlayerDied();
    }
}

fun void PlayerJumped(){
    PlayMarioJumpSound();
    Math.random2(1, 5) => int randomMove;
    if (randomMove == 1){
        PlayerCollectedCoin();
    }else if (randomMove == 2){
        PlayerHitMushroom();
    }else{
        <<<"Jump again">>>;
    }
}

//Initialize the game
<<<"=====================================================">>>;
<<<"Welcome to Super Mario Brothers - ChucK Edition">>>;
<<<"Your goal is to collect 10 coins">>>;
<<<"You have 100 health. Each time you hit a mushroom you will lose 10 health.">>>; 
<<<"Wait for the music to start, then you can play. Press spacebar to jump at random intervals">>>;
<<<"=====================================================">>>;

PlayNewMarioSound();
PlayMarioBackgroundMusic();
InitializeKeyboardListener();

//Handle keyboard events
while(true){
    hi => now;
    if (isPlayerAlive == 1 && playerScore <= 10){
        while(hi.recv(msg)){
            if(msg.isButtonDown()){
                if (msg.key == 44){
                    PlayerJumped();
                }
            }
        }
    }
}