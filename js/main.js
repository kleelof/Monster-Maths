import { generateQuestion } from "./questions.js";

const WIDTH = 800;
const HEIGHT = 500;
const TELEPORT_TIME = 4000;
const TELEPORT_RECHARGE_PER_MONSTER = 500;
const MONSTER_SPEED_MULTIPLIER = 1.5;
const EXPORT_ROOT = "mmswfs/monsterMathsswf";
const MONSTER_ANIMATIONS = {
  1: { folder: "DefineSprite_67_monsterMaths_fla.mon1walk_13", frames: 37 },
  2: { folder: "DefineSprite_77_monsterMaths_fla.mon2walk_11", frames: 25 },
  3: { folder: "DefineSprite_83_monsterMaths_fla.mon3walk_8", frames: 21 }
};

const campaign = {
  playerName: "Math Hero",
  hero: "girl",
  level: 1,
  wave: 1,
  score: 0,
  lives: 3,
  teleportCharge: TELEPORT_TIME
};

function resetCampaign(profile = {}) {
  campaign.playerName = profile.playerName || "Math Hero";
  campaign.hero = profile.hero || "girl";
  campaign.level = 1;
  campaign.wave = 1;
  campaign.score = 0;
  campaign.lives = 3;
  campaign.teleportCharge = TELEPORT_TIME;
}

function openProfileDialog() {
  const dialog = document.querySelector("#profile-dialog");
  const form = document.querySelector("#profile-form");
  const nameInput = document.querySelector("#player-name");
  dialog.showModal();
  requestAnimationFrame(() => nameInput.select());

  return new Promise((resolve) => {
    form.addEventListener("submit", () => {
      const data = new FormData(form);
      resolve({
        playerName: String(data.get("playerName") || "Math Hero").trim().slice(0, 16),
        hero: data.get("hero") === "boy" ? "boy" : "girl"
      });
    }, { once: true });
  });
}

class BootScene extends Phaser.Scene {
  constructor() { super("boot"); }

  preload() {
    this.load.image("title", "assets/images/title.png");
    this.load.spritesheet("heroes", "assets/images/bo.png", { frameWidth: 222, frameHeight: 352 });
    this.load.image("originalScore", `${EXPORT_ROOT}/sprites/DefineSprite_144_monsterMaths_fla.score_42/1.png`);
    this.load.image("originalGameOver", `${EXPORT_ROOT}/sprites/DefineSprite_23_gameOverMSG/1.png`);
    Object.entries(MONSTER_ANIMATIONS).forEach(([type, animation]) => {
      for (let frame = 1; frame <= animation.frames; frame += 1) {
        this.load.image(
          `monster${type}-walk-${frame}`,
          `${EXPORT_ROOT}/sprites/${animation.folder}/${frame}.png`
        );
      }
    });
    this.load.audio("titleMusic", "assets/audio/titleMusicTheme.mp3");
    this.load.audio("gameMusic", "assets/audio/gamePlayMusic.mp3");
    this.load.audio("wrong", "assets/audio/wrongAnswer.mp3");
    this.load.audio("boom", "assets/audio/boomSND.mp3");
  }

  create() {
    document.querySelector("#loading-message")?.remove();
    this.scene.start("menu");
  }
}

class MenuScene extends Phaser.Scene {
  constructor() { super("menu"); }

  create() {
    this.add.image(WIDTH / 2, HEIGHT / 2, "title").setDisplaySize(WIDTH, HEIGHT);
    const creditStyle = {
      fontFamily: "Comic Sans MS, cursive", fontSize: "18px", fontStyle: "bold",
      stroke: "#002416", strokeThickness: 3
    };
    this.add.text(242, 472, "Created By", { ...creditStyle, color: "#ffffff" })
      .setOrigin(0.5).setDepth(2);
    this.add.text(390, 451, "K. Lee Loftiss", { ...creditStyle, fontSize: "24px", color: "#ff1818" })
      .setOrigin(0.5).setDepth(2);
    this.add.text(523, 472, "And", { ...creditStyle, color: "#ffffff" })
      .setOrigin(0.5).setDepth(2);
    this.add.text(654, 451, "Shirhan Manan", { ...creditStyle, fontSize: "24px", color: "#ff1818" })
      .setOrigin(0.5).setDepth(2);
    this.titleMusic = this.sound.add("titleMusic", { loop: true, volume: 0.32 });
    const controls = document.querySelector("#menu-controls");
    const playButton = document.querySelector("#play-button");
    const instructionsButton = document.querySelector("#instructions-button");
    controls.hidden = false;

    const startTitleMusic = () => {
      if (!this.titleMusic.isPlaying) this.titleMusic.play();
    };

    playButton.onclick = async () => {
      startTitleMusic();
      const profile = await openProfileDialog();
      resetCampaign(profile);
      this.scene.start("game");
    };

    instructionsButton.onclick = () => {
      startTitleMusic();
      document.querySelector("#instructions-dialog").showModal();
    };

    this.events.once("shutdown", () => {
      controls.hidden = true;
      playButton.onclick = null;
      instructionsButton.onclick = null;
      this.titleMusic?.stop();
    });

  }
}

class GameScene extends Phaser.Scene {
  constructor() { super("game"); }

  create() {
    this.answering = false;
    this.roundOver = false;
    this.playerInvulnerable = false;
    this.teleportCharge = campaign.teleportCharge;
    this.teleporting = false;
    this.teleportExhausted = false;
    this.spaceHeld = false;
    this.mouseMoving = false;
    this.questionPanel = null;
    this.drawArena();

    const heroFrame = campaign.hero === "boy" ? 1 : 0;
    this.player = this.physics.add.sprite(400, 390, "heroes", heroFrame)
      .setDisplaySize(55, 87)
      .setCollideWorldBounds(true)
      .setDepth(4);
    this.player.body.setSize(34, 60);
    this.moveTarget = { x: this.player.x, y: this.player.y };
    this.input.on("pointerdown", (pointer) => {
      this.mouseMoving = true;
      this.updateMoveTarget(pointer);
    });
    this.input.on("pointermove", (pointer) => {
      if (this.mouseMoving) this.updateMoveTarget(pointer);
    });
    this.input.on("pointerup", () => {
      this.mouseMoving = false;
      this.player.setVelocity(0, 0);
      this.setTeleporting(false);
    });

    this.monsters = this.physics.add.group();
    this.spawnMonsters();
    this.physics.add.overlap(this.player, this.monsters, this.hitPlayer, null, this);

    this.keys = this.input.keyboard.addKeys("M");
    this.keys.M.on("down", () => this.toggleMute());
    this.spaceDownHandler = (event) => {
      if (event.code !== "Space") return;
      event.preventDefault();
      this.spaceHeld = true;
    };
    this.spaceUpHandler = (event) => {
      if (event.code !== "Space") return;
      event.preventDefault();
      this.spaceHeld = false;
      this.teleportExhausted = false;
      this.setTeleporting(false);
    };
    window.addEventListener("keydown", this.spaceDownHandler);
    window.addEventListener("keyup", this.spaceUpHandler);

    this.createHud();
    this.gameMusic = this.sound.add("gameMusic", { loop: true, volume: 0.3 });
    this.gameMusic.play();
    this.showWaveIntro();
    this.events.once("shutdown", () => {
      this.gameMusic?.stop();
      if (this.answerHandler) this.input.keyboard.off("keydown", this.answerHandler);
      window.removeEventListener("keydown", this.spaceDownHandler);
      window.removeEventListener("keyup", this.spaceUpHandler);
    });
  }

  drawArena() {
    const g = this.add.graphics();
    g.fillGradientStyle(0x004522, 0x004522, 0x002f17, 0x002f17, 1);
    g.fillRect(0, 0, WIDTH, HEIGHT);
  }

  createHud() {
    this.add.image(116, 38, "originalScore").setDisplaySize(205, 97).setDepth(10);
    this.add.ellipse(116, 42, 104, 42, 0x79ca18).setDepth(11);
    this.scoreText = this.add.text(116, 42, "", {
      fontFamily: "MonsterRavie, Ravie, fantasy", fontSize: "22px", color: "#7800d4",
      stroke: "#340061", strokeThickness: 2
    }).setOrigin(0.5).setDepth(12);

    this.levelText = this.add.text(400, 27, "", {
      fontFamily: "MonsterRavie, Ravie, fantasy", fontSize: "19px", color: "#ffffff",
      stroke: "#000000", strokeThickness: 4
    }).setOrigin(0.5).setDepth(11);

    this.livesIcons = [];
    for (let i = 0; i < 3; i += 1) {
      this.livesIcons.push(
        this.add.sprite(688 + i * 34, 27, "heroes", campaign.hero === "boy" ? 1 : 0)
          .setCrop(0, 0, 222, 190).setDisplaySize(32, 51).setDepth(11)
      );
    }
    this.muteText = this.add.text(731, 54, "SOUND", this.hudStyle("12px", "#ffffff"))
      .setDepth(11).setInteractive({ useHandCursor: true });
    this.muteText.on("pointerdown", (pointer, localX, localY, event) => {
      event.stopPropagation();
      this.mouseMoving = false;
      this.toggleMute();
    });

    this.add.text(266, 51, "TELE-ENERGY", this.hudStyle("11px", "#ffffff")).setDepth(11);
    this.add.rectangle(492, 57, 286, 13, 0x490000).setStrokeStyle(2, 0xffffff).setDepth(11);
    this.teleportBar = this.add.rectangle(350, 57, 0, 9, 0xd10000).setOrigin(0, 0.5).setDepth(12);
    this.teleportPercent = this.add.text(492, 57, "100%", this.hudStyle("11px", "#ffffff"))
      .setOrigin(0.5).setDepth(13);
    this.refreshHud();
  }

  hudStyle(size, color = "#ffffff") {
    return { fontFamily: "Trebuchet MS, sans-serif", fontSize: size, fontStyle: "bold", color };
  }

  refreshHud() {
    this.scoreText.setText(String(campaign.score));
    this.levelText.setText(`LEVEL ${campaign.level}  ·  WAVE ${campaign.wave}`);
    this.livesIcons?.forEach((icon, index) => icon.setVisible(index < campaign.lives));
  }

  spawnMonsters() {
    const count = [3, 5, 7][campaign.wave - 1];
    const baseSpeed = 22 + campaign.level * 1.8 + campaign.wave * 3;
    const monsterTypes = [
      {
        type: 1,
        size: [58, 92],
        speed: baseSpeed * 0.7,
        questionLevel: Math.max(1, campaign.level - 1)
      },
      {
        type: 3,
        size: [104, 78],
        speed: baseSpeed,
        questionLevel: campaign.level
      },
      {
        type: 2,
        size: [61, 92],
        speed: baseSpeed * 1.45,
        questionLevel: Math.min(10, campaign.level + 1)
      }
    ];

    for (let i = 0; i < count; i += 1) {
      const config = monsterTypes[i % monsterTypes.length];
      const point = this.randomArenaPoint();
      const monster = this.monsters.create(point.x, point.y, `monster${config.type}-walk-1`);
      monster.setCollideWorldBounds(true).setBounce(1).setDepth(3);
      monster.body.setSize(config.size[0] * 0.7, config.size[1] * 0.72);
      monster.monsterType = config.type;
      monster.questionLevel = config.questionLevel;
      monster.question = generateQuestion(monster.questionLevel);
      monster.moveSpeed = (config.speed + i * 0.5) * MONSTER_SPEED_MULTIPLIER;
      monster.pursuitAngle = (Math.PI * 2 * i) / count;
      monster.pursuitRadius = 22 + (i % 3) * 7;
      monster.wobbleOffset = Math.random() * Math.PI * 2;
      monster.walkFrame = 1;
      monster.lastWalkFrame = 0;
      monster.walkFrameCount = MONSTER_ANIMATIONS[config.type].frames;
      monster.setInteractive({ pixelPerfect: true, alphaTolerance: 8, useHandCursor: true });
      monster.on("pointerdown", (pointer, localX, localY, event) => {
        event.stopPropagation();
        this.mouseMoving = false;
        this.player.setVelocity(0, 0);
        this.askMonster(monster);
      });
    }
  }

  randomArenaPoint() {
    let x;
    let y;
    do {
      x = Phaser.Math.Between(65, 735);
      y = Phaser.Math.Between(115, 360);
    } while (Phaser.Math.Distance.Between(x, y, 400, 390) < 150);
    return { x, y };
  }

  updateMoveTarget(pointer) {
    this.moveTarget.x = Phaser.Math.Clamp(pointer.worldX, 35, WIDTH - 35);
    this.moveTarget.y = Phaser.Math.Clamp(pointer.worldY, 100, HEIGHT - 35);
  }

  update(time, delta) {
    if (this.answering || this.roundOver) return;

    if (this.mouseMoving && this.spaceHeld && !this.teleportExhausted && this.teleportCharge > 0) {
      this.setTeleporting(true);
      this.teleportCharge = Math.max(0, this.teleportCharge - delta);
      this.player.setPosition(this.moveTarget.x, this.moveTarget.y);
      this.player.setVelocity(0, 0);
      if (this.teleportCharge === 0) {
        this.teleportExhausted = true;
        this.setTeleporting(false);
      }
    } else {
      this.setTeleporting(false);
      const dx = this.moveTarget.x - this.player.x;
      const dy = this.moveTarget.y - this.player.y;
      const distance = Math.hypot(dx, dy);
      if (this.mouseMoving && distance > 6) {
        const speed = 190;
        this.player.setVelocity(dx / distance * speed, dy / distance * speed);
        this.player.setFlipX(dx < 0);
      } else {
        this.player.setVelocity(0, 0);
      }
    }

    for (const monster of this.monsters.getChildren()) {
      if (!monster?.active) continue;
      const pursuitAngle = monster.pursuitAngle + time * 0.00016;
      const targetX = this.player.x + Math.cos(pursuitAngle) * monster.pursuitRadius;
      const targetY = this.player.y + Math.sin(pursuitAngle) * monster.pursuitRadius;
      this.physics.moveTo(monster, targetX, targetY, monster.moveSpeed);
      monster.rotation = Math.sin(time / 220 + monster.wobbleOffset) * 0.045;
      monster.setFlipX(monster.body.velocity.x > 0);
      if (time - monster.lastWalkFrame > 55) {
        monster.walkFrame = monster.walkFrame % monster.walkFrameCount + 1;
        monster.setTexture(`monster${monster.monsterType}-walk-${monster.walkFrame}`);
        monster.lastWalkFrame = time;
      }
    }

    const teleRatio = this.teleportCharge / TELEPORT_TIME;
    this.teleportBar.width = 282 * teleRatio;
    this.teleportBar.setFillStyle(teleRatio > 0.25 ? 0xd10000 : 0xffe600);
    this.teleportPercent.setText(`${Math.round(teleRatio * 100)}%`);
    campaign.teleportCharge = this.teleportCharge;

  }

  setTeleporting(active) {
    if (this.teleporting === active) return;
    this.teleporting = active;
    this.player.setAlpha(active ? 0.45 : 1);
  }

  showWaveIntro() {
    this.roundOver = true;
    const items = [];
    const panel = this.add.rectangle(400, 258, 520, 190, 0x000000, 0.88)
      .setStrokeStyle(4, 0xffffff).setDepth(25);
    const details = this.add.text(400, 225, `LEVEL:  ${campaign.level}     WAVE:  ${campaign.wave}`, {
      fontFamily: "MonsterRavie, Ravie, fantasy", fontSize: "27px", color: "#ffffff",
      stroke: "#000000", strokeThickness: 5
    }).setOrigin(0.5).setDepth(26);
    const ready = this.add.text(400, 292, "GET READY!!!", {
      fontFamily: "MonsterRavie, Ravie, fantasy", fontSize: "44px", color: "#ff4141",
      stroke: "#ffffff", strokeThickness: 3
    }).setOrigin(0.5).setDepth(26);
    items.push(panel, details, ready);
    this.time.delayedCall(1350, () => {
      items.forEach((item) => item.destroy());
      this.roundOver = false;
    });
  }

  askMonster(monster) {
    if (this.answering || this.roundOver || !monster.active) return;
    this.answering = true;
    this.currentMonster = monster;
    this.mouseMoving = false;
    this.setTeleporting(false);
    this.player.setVelocity(0);
    for (const enemy of this.monsters.getChildren()) enemy.setVelocity(0, 0);
    this.showQuestion(monster.question);
  }

  hitPlayer(player) {
    if (this.answering || this.roundOver || this.playerInvulnerable || this.teleporting) return;

    this.playerInvulnerable = true;
    campaign.lives -= 1;
    player.setVelocity(0, 0);
    this.sound.play("wrong", { volume: 0.7 });
    this.cameras.main.shake(260, 0.015);
    this.refreshHud();

    if (campaign.lives <= 0) {
      this.finishGame(false);
      return;
    }

    this.teleportCharge = TELEPORT_TIME;
    campaign.teleportCharge = TELEPORT_TIME;
    this.teleportExhausted = false;
    this.setTeleporting(false);

    player.setPosition(400, 390);
    this.moveTarget.x = 400;
    this.moveTarget.y = 390;
    for (const monster of this.monsters.getChildren()) {
      monster.setVelocity(0, 0);
      const point = this.randomArenaPoint();
      monster.setPosition(point.x, point.y);
    }

    const warning = this.add.text(400, 105, "LIFE LOST!", {
      fontFamily: "Trebuchet MS", fontSize: "32px", fontStyle: "bold", color: "#ff6b6b",
      stroke: "#3a0909", strokeThickness: 5
    }).setOrigin(0.5).setDepth(15);

    this.tweens.add({
      targets: player,
      alpha: 0.2,
      duration: 120,
      yoyo: true,
      repeat: 3,
      onComplete: () => {
        player.setAlpha(1);
        this.playerInvulnerable = false;
        warning.destroy();
      }
    });
  }

  showQuestion(question) {
    let answer = "";
    let submitted = false;
    const x = Phaser.Math.Clamp(this.currentMonster.x - 115, 105, WIDTH - 105);
    const y = Phaser.Math.Clamp(this.currentMonster.y - 55, 185, HEIGHT - 145);
    const items = [];
    const panel = this.add.rectangle(x, y, 190, 272, 0xf5f5f5)
      .setStrokeStyle(5, 0xc82121).setDepth(21);
    const screen = this.add.rectangle(x, y - 95, 164, 62, 0xd9d9d9)
      .setStrokeStyle(2, 0x333333).setDepth(22);
    const prompt = this.add.text(x, y - 111, question.text, {
      fontFamily: "Arial, sans-serif", fontSize: "23px", fontStyle: "bold", color: "#ffffff",
      stroke: "#777777", strokeThickness: 3
    }).setOrigin(0.5).setDepth(23);
    const answerText = this.add.text(x, y - 80, "?", {
      fontFamily: "Arial, sans-serif", fontSize: "24px", fontStyle: "bold", color: "#e00000"
    }).setOrigin(0.5).setDepth(23);
    items.push(panel, screen, prompt, answerText);

    const addButton = (label, bx, by, action, color = 0xffffff) => {
      const button = this.add.rectangle(bx, by, 42, 34, color)
        .setStrokeStyle(2, 0xc82121).setDepth(22).setInteractive({ useHandCursor: true });
      const text = this.add.text(bx, by, label, {
        fontFamily: "Arial, sans-serif", fontSize: "21px", fontStyle: "bold", color: "#142b70"
      }).setOrigin(0.5).setDepth(23);
      button.on("pointerdown", (pointer, localX, localY, event) => {
        event.stopPropagation();
        action();
      });
      items.push(button, text);
    };

    const processKey = (key) => {
      if (submitted) return;
      if (/^[0-9]$/.test(key) && answer.length < 4) answer += key;
      if (key === "Backspace") answer = answer.slice(0, -1);
      answerText.setText(answer || "?");
      if (key === "Enter" && answer !== "") {
        submitted = true;
        this.checkAnswer(Number(answer), question.result);
      }
    };

    [["1", -52], ["2", 0], ["3", 52]].forEach(([digit, offset]) => addButton(digit, x + offset, y - 35, () => processKey(digit)));
    [["4", -52], ["5", 0], ["6", 52]].forEach(([digit, offset]) => addButton(digit, x + offset, y + 5, () => processKey(digit)));
    [["7", -52], ["8", 0], ["9", 52]].forEach(([digit, offset]) => addButton(digit, x + offset, y + 45, () => processKey(digit)));
    addButton("0", x, y + 85, () => processKey("0"));
    addButton("←", x - 52, y + 85, () => this.closeQuestion(), 0xffef5d);
    addButton("✓", x + 52, y + 85, () => processKey("Enter"), 0x8ee36b);
    this.questionPanel = items;
    this.currentMonster.setTint(0x89c9ff);

    this.answerHandler = (event) => {
      if (/^[0-9]$/.test(event.key) || event.key === "Backspace" || event.key === "Enter") {
        processKey(event.key);
        event.preventDefault();
      }
    };
    this.input.keyboard.on("keydown", this.answerHandler);
  }

  closeQuestion() {
    if (!this.answering || !this.questionPanel) return;
    this.input.keyboard.off("keydown", this.answerHandler);
    this.questionPanel.forEach((item) => item.destroy());
    this.questionPanel = null;
    this.currentMonster?.clearTint();
    this.answering = false;
  }

  checkAnswer(answer, result) {
    this.input.keyboard.off("keydown", this.answerHandler);
    this.questionPanel.forEach((item) => item.destroy());
    this.questionPanel = null;
    this.currentMonster.clearTint();

    if (answer === result) {
      campaign.score += ({ 1: 10, 2: 15, 3: 25 })[this.currentMonster.monsterType] || 10;
      this.teleportCharge = Math.min(
        TELEPORT_TIME,
        this.teleportCharge + TELEPORT_RECHARGE_PER_MONSTER
      );
      campaign.teleportCharge = this.teleportCharge;
      this.sound.play("boom", { volume: 0.55 });
      const defeated = this.currentMonster;
      defeated.disableInteractive();
      this.createExplosion(defeated.x, defeated.y, defeated.monsterType);
      this.tweens.add({
        targets: defeated, alpha: 0, scaleX: 1.7, scaleY: 0.25, angle: 90, duration: 280,
        onComplete: () => {
          defeated.destroy();
          this.answering = false;
          this.refreshHud();
          if (!this.monsters.getChildren().some((monster) => monster.active)) this.completeWave();
        }
      });
    } else {
      this.sound.play("wrong", { volume: 0.65 });
      this.cameras.main.shake(220, 0.012);
      this.currentMonster.question = generateQuestion(this.currentMonster.questionLevel);
      this.time.delayedCall(360, () => {
        this.answering = false;
      });
    }
  }

  completeWave() {
    this.roundOver = true;
    this.teleportCharge = TELEPORT_TIME;
    campaign.teleportCharge = TELEPORT_TIME;
    const finalWin = campaign.level === 10 && campaign.wave === 3;
    if (finalWin) { this.finishGame(true); return; }

    const nextLevel = campaign.wave === 3;
    this.showMessage(
      nextLevel ? `LEVEL ${campaign.level} CLEAR!` : "WAVE CLEAR!",
      nextLevel ? "A new maths challenge awaits." : "The next monster wave is ready.",
      "CONTINUE",
      () => {
        if (nextLevel) { campaign.level += 1; campaign.wave = 1; }
        else campaign.wave += 1;
        this.scene.restart();
      }
    );
  }

  createExplosion(x, y, monsterType) {
    const palettes = {
      1: [0x8d7cff, 0x5b47cf, 0xd7ceff],
      2: [0x4cd8ff, 0x2584d8, 0xc8f5ff],
      3: [0xff6f72, 0xffb14e, 0xffe36b]
    };
    const colors = palettes[monsterType] || palettes[3];

    const ring = this.add.circle(x, y, 13, 0xffffff, 0)
      .setStrokeStyle(5, colors[2], 0.95)
      .setDepth(14);
    this.tweens.add({
      targets: ring,
      scale: 4.5,
      alpha: 0,
      duration: 380,
      ease: "Cubic.Out",
      onComplete: () => ring.destroy()
    });

    for (let i = 0; i < 18; i += 1) {
      const angle = Math.PI * 2 * i / 18 + Phaser.Math.FloatBetween(-0.12, 0.12);
      const distance = Phaser.Math.Between(42, 105);
      const particle = this.add.circle(
        x,
        y,
        Phaser.Math.Between(3, 8),
        colors[i % colors.length],
        1
      ).setDepth(14);

      this.tweens.add({
        targets: particle,
        x: x + Math.cos(angle) * distance,
        y: y + Math.sin(angle) * distance,
        scale: 0.15,
        alpha: 0,
        duration: Phaser.Math.Between(320, 620),
        ease: "Cubic.Out",
        onComplete: () => particle.destroy()
      });
    }
  }

  finishGame(won) {
    this.roundOver = true;
    this.player.setVelocity(0);
    for (const monster of this.monsters.getChildren()) monster.setVelocity(0, 0);
    this.showMessage(
      won ? "MATHS MASTER!" : "GAME OVER",
      won ? `You cleared every level with ${campaign.score} points.` : `Final score: ${campaign.score}`,
      "PLAY AGAIN",
      () => { resetCampaign(campaign); this.scene.restart(); },
      true
    );
  }

  showMessage(title, message, buttonLabel, onContinue, showMenu = false) {
    this.add.rectangle(400, 285, 800, 430, 0x020d09, 0.82).setDepth(30);
    if (showMenu) {
      this.add.image(400, 255, "originalGameOver").setDepth(31);
      const replay = this.add.rectangle(400, 383, 250, 65, 0xffffff, 0.001)
        .setInteractive({ useHandCursor: true }).setDepth(33);
      replay.once("pointerdown", onContinue);
      const score = this.add.text(400, 322, `SCORE: ${campaign.score}`, {
        fontFamily: "MonsterRavie, Ravie, fantasy", fontSize: "18px", color: "#ffffff",
        stroke: "#000000", strokeThickness: 4
      }).setOrigin(0.5).setDepth(33);
      const menu = this.add.text(400, 464, "BACK TO TITLE", this.hudStyle("15px", "#ffffff"))
        .setOrigin(0.5).setInteractive({ useHandCursor: true }).setDepth(33);
      menu.once("pointerdown", () => this.scene.start("menu"));
      return;
    }

    this.add.rectangle(400, 275, 520, 290, 0x000000, 0.9)
      .setStrokeStyle(4, 0xffffff).setDepth(31);
    this.add.text(400, 190, `LEVEL:  ${campaign.level}     WAVE:  ${campaign.wave}`, {
      fontFamily: "MonsterRavie, Ravie, fantasy", fontSize: "25px", color: "#ffffff",
      stroke: "#000000", strokeThickness: 4
    }).setOrigin(0.5).setDepth(32);
    this.add.text(400, 256, title, {
      fontFamily: "MonsterRavie, Ravie, fantasy", fontSize: "44px", color: "#fff600",
      stroke: "#ffffff", strokeThickness: 2
    }).setOrigin(0.5).setDepth(32);
    this.add.text(400, 306, message, {
      fontFamily: "Trebuchet MS", fontSize: "17px", color: "#ffffff", align: "center"
    }).setOrigin(0.5).setDepth(32);
    const button = this.add.rectangle(400, 365, 230, 48, 0xd81919)
      .setStrokeStyle(3, 0xffff00).setInteractive({ useHandCursor: true }).setDepth(32);
    this.add.text(400, 365, buttonLabel, {
      fontFamily: "MonsterRavie, Ravie, fantasy", fontSize: "17px", color: "#ffffff"
    }).setOrigin(0.5).setDepth(33);
    button.once("pointerdown", onContinue);
  }

  toggleMute() {
    this.sound.mute = !this.sound.mute;
    this.muteText?.setText(this.sound.mute ? "MUTED" : "SOUND");
  }
}

const config = {
  type: Phaser.CANVAS,
  width: WIDTH,
  height: HEIGHT,
  parent: "game-container",
  backgroundColor: "#082d20",
  pixelArt: false,
  antialias: true,
  physics: {
    default: "arcade",
    arcade: { gravity: { x: 0, y: 0 }, debug: false }
  },
  scale: { mode: Phaser.Scale.NONE, autoCenter: Phaser.Scale.CENTER_BOTH },
  scene: [BootScene, MenuScene, GameScene]
};

window.monsterMathsGame = new Phaser.Game(config);
