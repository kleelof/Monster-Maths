import { generateQuestion } from "./questions.js";

const WIDTH = 800;
const HEIGHT = 500;
const TELEPORT_TIME = 4000;

const campaign = {
  playerName: "Math Hero",
  hero: "girl",
  level: 1,
  stage: 1,
  score: 0,
  lives: 3
};

function resetCampaign(profile = {}) {
  campaign.playerName = profile.playerName || "Math Hero";
  campaign.hero = profile.hero || "girl";
  campaign.level = 1;
  campaign.stage = 1;
  campaign.score = 0;
  campaign.lives = 3;
}

function makeButton(scene, x, y, label, onClick, width = 230) {
  const background = scene.add.rectangle(x, y, width, 54, 0xb9e94b)
    .setStrokeStyle(4, 0x345d22)
    .setInteractive({ useHandCursor: true });
  const text = scene.add.text(x, y, label, {
    fontFamily: "Trebuchet MS, sans-serif",
    fontSize: "24px",
    fontStyle: "bold",
    color: "#173009"
  }).setOrigin(0.5);

  background.on("pointerover", () => background.setFillStyle(0xffef54));
  background.on("pointerout", () => background.setFillStyle(0xb9e94b));
  background.on("pointerdown", () => { background.setScale(0.97); onClick(); });
  background.on("pointerup", () => background.setScale(1));
  return scene.add.container(0, 0, [background, text]);
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
    this.load.image("logo", "assets/images/logo.png");
    this.load.spritesheet("heroes", "assets/images/bo.png", { frameWidth: 222, frameHeight: 352 });
    this.load.image("monster1", "assets/images/mon1.png");
    this.load.image("monster2", "assets/images/mon2.png");
    this.load.image("monster3", "assets/images/mon3.png");
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
    this.add.rectangle(WIDTH / 2, 438, WIDTH, 124, 0x041a12, 0.82);
    this.titleMusic = this.sound.add("titleMusic", { loop: true, volume: 0.32 });
    this.input.once("pointerdown", () => this.titleMusic.play());
    this.events.once("shutdown", () => this.titleMusic?.stop());

    makeButton(this, 270, 438, "PLAY", async () => {
      const profile = await openProfileDialog();
      resetCampaign(profile);
      this.scene.start("game");
    }, 210);

    makeButton(this, 530, 438, "HOW TO PLAY", () => {
      document.querySelector("#instructions-dialog").showModal();
    }, 240);

    this.add.text(14, 12, "Browser Edition", {
      fontFamily: "Trebuchet MS", fontSize: "15px", color: "#d8efb4",
      backgroundColor: "#06231bb5", padding: { x: 9, y: 5 }
    });
  }
}

class GameScene extends Phaser.Scene {
  constructor() { super("game"); }

  create() {
    this.answering = false;
    this.roundOver = false;
    this.playerInvulnerable = false;
    this.teleportCharge = TELEPORT_TIME;
    this.teleporting = false;
    this.teleportExhausted = false;
    this.spaceHeld = false;
    this.mouseMoving = false;
    this.questionPanel = null;
    this.drawArena();

    const heroFrame = campaign.hero === "boy" ? 1 : 0;
    this.player = this.physics.add.sprite(400, 390, "heroes", heroFrame)
      .setDisplaySize(66, 104)
      .setCollideWorldBounds(true)
      .setDepth(4);
    this.player.body.setSize(40, 70).setOffset(91, 118);
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
    this.events.once("shutdown", () => {
      this.gameMusic?.stop();
      if (this.answerHandler) this.input.keyboard.off("keydown", this.answerHandler);
      window.removeEventListener("keydown", this.spaceDownHandler);
      window.removeEventListener("keyup", this.spaceUpHandler);
    });
  }

  drawArena() {
    const g = this.add.graphics();
    g.fillGradientStyle(0x0d5739, 0x0d5739, 0x06291e, 0x06291e, 1);
    g.fillRect(0, 0, WIDTH, HEIGHT);
    g.fillStyle(0x79b952, 0.11);
    for (let y = 82; y < HEIGHT; y += 52) {
      for (let x = (y / 52) % 2 ? 18 : 44; x < WIDTH; x += 70) g.fillCircle(x, y, 3);
    }
    g.lineStyle(4, 0x93d75a, 0.5);
    g.strokeRoundedRect(12, 72, WIDTH - 24, HEIGHT - 84, 18);
  }

  createHud() {
    this.add.rectangle(WIDTH / 2, 33, WIDTH, 66, 0x041a13, 0.96).setDepth(10);
    this.nameText = this.add.text(18, 13, campaign.playerName, this.hudStyle("20px", "#ffe957")).setDepth(11);
    this.scoreText = this.add.text(18, 39, "", this.hudStyle("15px")).setDepth(11);
    this.levelText = this.add.text(400, 33, "", this.hudStyle("21px", "#b9f477")).setOrigin(0.5).setDepth(11);
    this.livesText = this.add.text(674, 12, "", this.hudStyle("18px", "#ff8c8c")).setDepth(11);
    this.muteText = this.add.text(734, 41, "SOUND", this.hudStyle("12px", "#d8efca"))
      .setDepth(11).setInteractive({ useHandCursor: true });
    this.muteText.on("pointerdown", (pointer, localX, localY, event) => {
      event.stopPropagation();
      this.mouseMoving = false;
      this.toggleMute();
    });

    this.add.text(544, 42, "TELEPORT", this.hudStyle("11px", "#d8efca")).setDepth(11);
    this.add.rectangle(646, 49, 78, 12, 0x142f27).setStrokeStyle(1, 0xb4d99a).setDepth(11);
    this.teleportBar = this.add.rectangle(607, 49, 0, 8, 0x73e4ff).setOrigin(0, 0.5).setDepth(12);
    this.refreshHud();
  }

  hudStyle(size, color = "#ffffff") {
    return { fontFamily: "Trebuchet MS, sans-serif", fontSize: size, fontStyle: "bold", color };
  }

  refreshHud() {
    this.scoreText.setText(`Score ${campaign.score}`);
    this.levelText.setText(`Level ${campaign.level}`);
    this.livesText.setText(`Lives ${"●".repeat(Math.max(0, campaign.lives))}`);
  }

  spawnMonsters() {
    const count = Math.min(2 + campaign.stage + Math.floor((campaign.level - 1) / 3), 7);
    const baseSpeed = 22 + campaign.level * 1.8 + campaign.stage * 3;
    const monsterTypes = [
      {
        type: 1,
        key: "monster1",
        size: [58, 92],
        speed: baseSpeed * 0.7,
        questionLevel: Math.max(1, campaign.level - 1)
      },
      {
        type: 3,
        key: "monster3",
        size: [104, 78],
        speed: baseSpeed,
        questionLevel: campaign.level
      },
      {
        type: 2,
        key: "monster2",
        size: [61, 92],
        speed: baseSpeed * 1.45,
        questionLevel: Math.min(10, campaign.level + 1)
      }
    ];

    for (let i = 0; i < count; i += 1) {
      const config = monsterTypes[i % monsterTypes.length];
      const point = this.randomArenaPoint();
      const monster = this.monsters.create(point.x, point.y, config.key);
      monster.setDisplaySize(...config.size);
      monster.setCollideWorldBounds(true).setBounce(1).setDepth(3);
      monster.body.setSize(monster.displayWidth * 0.68, monster.displayHeight * 0.72);
      monster.monsterType = config.type;
      monster.questionLevel = config.questionLevel;
      monster.question = generateQuestion(monster.questionLevel);
      monster.moveSpeed = config.speed + i * 0.5;
      monster.wobbleOffset = Math.random() * Math.PI * 2;
      monster.setInteractive({ useHandCursor: true });
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
      if (!this.teleporting) {
        this.teleportCharge = Math.min(TELEPORT_TIME, this.teleportCharge + delta * 0.55);
      }
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
      this.physics.moveToObject(monster, this.player, monster.moveSpeed);
      monster.rotation = Math.sin(time / 220 + monster.wobbleOffset) * 0.045;
    }

    this.teleportBar.width = 74 * (this.teleportCharge / TELEPORT_TIME);
    this.teleportBar.setFillStyle(this.teleportCharge >= TELEPORT_TIME ? 0xffeb4c : 0x73e4ff);

  }

  setTeleporting(active) {
    if (this.teleporting === active) return;
    this.teleporting = active;
    this.player.setAlpha(active ? 0.45 : 1);
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
    const shade = this.add.rectangle(400, 285, 800, 430, 0x020d09, 0.72).setDepth(20);
    const panel = this.add.rectangle(400, 282, 460, 260, 0xf4ffe5)
      .setStrokeStyle(8, 0x74b834).setDepth(21);
    const difficulty = this.add.text(
      400,
      166,
      `MONSTER ${this.currentMonster.monsterType} · LEVEL ${this.currentMonster.questionLevel} QUESTION`,
      { fontFamily: "Trebuchet MS", fontSize: "14px", fontStyle: "bold", color: "#527348" }
    ).setOrigin(0.5).setDepth(22);
    const prompt = this.add.text(400, 205, question.text, {
      fontFamily: "Trebuchet MS", fontSize: "58px", fontStyle: "bold", color: "#183c25"
    }).setOrigin(0.5).setDepth(22);
    const answerText = this.add.text(400, 292, "?", {
      fontFamily: "Trebuchet MS", fontSize: "46px", fontStyle: "bold", color: "#245d3a",
      backgroundColor: "#d9efbd", padding: { x: 25, y: 8 }, fixedWidth: 250, align: "center"
    }).setOrigin(0.5).setDepth(22);
    const help = this.add.text(400, 370, "Type your answer, then press Enter", {
      fontFamily: "Trebuchet MS", fontSize: "17px", color: "#31513d"
    }).setOrigin(0.5).setDepth(22);
    this.questionPanel = [shade, panel, difficulty, prompt, answerText, help];

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

    this.answerHandler = (event) => {
      if (/^[0-9]$/.test(event.key) || event.key === "Backspace" || event.key === "Enter") {
        processKey(event.key);
        event.preventDefault();
      }
    };
    this.input.keyboard.on("keydown", this.answerHandler);
  }

  checkAnswer(answer, result) {
    this.input.keyboard.off("keydown", this.answerHandler);
    this.questionPanel.forEach((item) => item.destroy());
    this.questionPanel = null;

    if (answer === result) {
      campaign.score += 100 * campaign.level + 25 * campaign.stage;
      this.teleportCharge = Math.min(TELEPORT_TIME, this.teleportCharge + 1100);
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
          if (!this.monsters.getChildren().some((monster) => monster.active)) this.completeStage();
        }
      });
    } else {
      campaign.lives -= 1;
      this.sound.play("wrong", { volume: 0.65 });
      this.cameras.main.shake(220, 0.012);
      const point = this.randomArenaPoint();
      this.currentMonster.setPosition(point.x, point.y);
      this.currentMonster.question = generateQuestion(this.currentMonster.questionLevel);
      this.time.delayedCall(360, () => {
        this.answering = false;
        this.refreshHud();
        if (campaign.lives <= 0) this.finishGame(false);
      });
    }
  }

  completeStage() {
    this.roundOver = true;
    const finalWin = campaign.level === 10 && campaign.stage === 3;
    if (finalWin) { this.finishGame(true); return; }

    const nextLevel = campaign.stage === 3;
    this.showMessage(
      nextLevel ? `LEVEL ${campaign.level} CLEAR!` : "WAVE CLEAR!",
      nextLevel ? "A new maths challenge awaits." : "The next monster wave is ready.",
      "CONTINUE",
      () => {
        if (nextLevel) { campaign.level += 1; campaign.stage = 1; }
        else campaign.stage += 1;
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
    this.add.rectangle(400, 275, 560, 270, 0x123d2b).setStrokeStyle(7, 0xaadf55).setDepth(31);
    this.add.text(400, 205, title, {
      fontFamily: "Trebuchet MS", fontSize: "42px", fontStyle: "bold", color: "#ffed52"
    }).setOrigin(0.5).setDepth(32);
    this.add.text(400, 268, message, {
      fontFamily: "Trebuchet MS", fontSize: "19px", color: "#efffdf", align: "center",
      wordWrap: { width: 470 }
    }).setOrigin(0.5).setDepth(32);
    const button = this.add.rectangle(400, 344, 230, 50, 0xb9e94b)
      .setStrokeStyle(3, 0x365d24).setInteractive({ useHandCursor: true }).setDepth(32);
    this.add.text(400, 344, buttonLabel, this.hudStyle("20px", "#173009")).setOrigin(0.5).setDepth(33);
    button.once("pointerdown", onContinue);
    if (showMenu) {
      const menu = this.add.text(400, 397, "Back to title", this.hudStyle("16px", "#ccebb4"))
        .setOrigin(0.5).setInteractive({ useHandCursor: true }).setDepth(33);
      menu.once("pointerdown", () => this.scene.start("menu"));
    }
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
  scale: { mode: Phaser.Scale.FIT, autoCenter: Phaser.Scale.CENTER_BOTH },
  scene: [BootScene, MenuScene, GameScene]
};

new Phaser.Game(config);
