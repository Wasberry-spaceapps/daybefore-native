import { useEffect, useRef } from 'react';
import './index.css';

interface GameProps {
  onClose: () => void;
}

export default function Game({ onClose }: GameProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animationId: number;
    let frames = 0;
    let score = 0;
    
    // Game state
    const groundHeight = 40;
    
    const car = {
      x: 50,
      y: canvas.height - groundHeight - 20,
      width: 40,
      height: 20,
      dy: 0,
      jumpForce: -10,
      originalY: canvas.height - groundHeight - 20,
      grounded: false
    };
    
    const gravity = 0.6;
    let speed = 4;
    
    interface Obstacle {
      x: number;
      y: number;
      width: number;
      height: number;
      type: 'rock' | 'branch';
    }
    
    let obstacles: Obstacle[] = [];
    let isGameOver = false;

    // Draw functions using design system colors
    const colors = {
      accent: '#7C98B3',
      textSecondary: '#888888',
      divider: '#2A2A2A',
      bg: '#111111'
    };

    const drawCar = () => {
      ctx.fillStyle = colors.textSecondary;
      ctx.beginPath();
      // Simple car silhouette
      ctx.rect(car.x, car.y, car.width, car.height);
      ctx.rect(car.x + 8, car.y - 12, 20, 12);
      ctx.fill();
    };

    const drawObstacles = () => {
      ctx.fillStyle = colors.divider;
      obstacles.forEach(obs => {
        ctx.beginPath();
        if (obs.type === 'rock') {
          // simple rock polygon
          ctx.moveTo(obs.x, obs.y + obs.height);
          ctx.lineTo(obs.x + obs.width/2, obs.y);
          ctx.lineTo(obs.x + obs.width, obs.y + obs.height);
          ctx.fill();
        } else {
          // simple branch rectangle
          ctx.rect(obs.x, obs.y, obs.width, obs.height);
          ctx.fill();
        }
      });
    };

    const drawGround = () => {
      ctx.fillStyle = colors.divider;
      ctx.fillRect(0, canvas.height - groundHeight, canvas.width, 1);
    };
    
    const drawScore = () => {
      ctx.fillStyle = colors.textSecondary;
      ctx.font = '14px system-ui, sans-serif';
      ctx.fillText(`Distance: ${Math.floor(score)}`, 20, 30);
    };

    const jump = () => {
      if (car.grounded && !isGameOver) {
        car.dy = car.jumpForce;
        car.grounded = false;
      }
    };

    const handleInput = (e: KeyboardEvent | TouchEvent | MouseEvent) => {
      if (isGameOver) {
        isGameOver = false;
        frames = 0;
        score = 0;
        speed = 4;
        obstacles = [];
        car.y = car.originalY;
        car.dy = 0;
        car.grounded = true;
        update();
        return;
      }
      
      if (e.type === 'keydown') {
        const ke = e as KeyboardEvent;
        if (ke.code === 'Space') jump();
      } else {
        jump();
      }
    };

    window.addEventListener('keydown', handleInput);
    canvas.addEventListener('mousedown', handleInput);
    canvas.addEventListener('touchstart', handleInput);

    const update = () => {
      if (isGameOver) {
        ctx.fillStyle = colors.textSecondary;
        ctx.font = '20px system-ui, sans-serif';
        ctx.fillText('Finished. Tap or press Space to restart.', canvas.width / 2 - 160, canvas.height / 2);
        return;
      }

      ctx.clearRect(0, 0, canvas.width, canvas.height);

      // Physics
      car.y += car.dy;
      if (car.y + car.height < canvas.height - groundHeight) {
        car.dy += gravity;
        car.grounded = false;
      } else {
        car.dy = 0;
        car.grounded = true;
        car.y = canvas.height - groundHeight - car.height;
      }

      // Obstacles spawn
      if (frames % Math.max(80, 150 - Math.floor(score / 50)) === 0) {
        const type = Math.random() > 0.5 ? 'rock' : 'branch';
        obstacles.push({
          x: canvas.width,
          y: canvas.height - groundHeight - (type === 'rock' ? 15 : 5),
          width: type === 'rock' ? 20 : 30,
          height: type === 'rock' ? 15 : 5,
          type
        });
      }

      // Obstacles update & collision
      obstacles.forEach(obs => {
        obs.x -= speed;
        // Collision
        if (
          car.x < obs.x + obs.width &&
          car.x + car.width > obs.x &&
          car.y < obs.y + obs.height &&
          car.y + car.height > obs.y
        ) {
          isGameOver = true;
        }
      });

      obstacles = obstacles.filter(obs => obs.x + obs.width > 0);

      // Score and speed
      score += 0.1;
      if (frames % 600 === 0 && speed < 8) speed += 0.5;

      drawGround();
      drawObstacles();
      drawCar();
      drawScore();

      frames++;
      animationId = requestAnimationFrame(update);
    };

    update();

    return () => {
      window.removeEventListener('keydown', handleInput);
      canvas.removeEventListener('mousedown', handleInput);
      canvas.removeEventListener('touchstart', handleInput);
      cancelAnimationFrame(animationId);
    };
  }, []);

  return (
    <div className="game-overlay">
      <div className="game-container">
        <div className="game-header">
          <button onClick={onClose} className="text-btn">close</button>
        </div>
        <canvas 
          ref={canvasRef} 
          width={600} 
          height={200}
          className="game-canvas"
        />
      </div>
    </div>
  );
}
