'use client';

import { Environment, Float, RoundedBox } from '@react-three/drei';
import { Canvas, useFrame } from '@react-three/fiber';
import { useRef } from 'react';
import * as THREE from 'three';

export function HeroPhone() {
  return (
    <div className="hero-phone-canvas" aria-label="Interactive Atlas phone preview">
      <Canvas dpr={[1, 1.65]} camera={{ position: [0, 0.1, 6.2], fov: 38 }} gl={{ antialias: true, alpha: true }}>
        <ambientLight intensity={1.1} />
        <directionalLight position={[3, 4, 5]} intensity={2.2} />
        <pointLight position={[-3, -2, 4]} intensity={2} color="#2563FF" />
        <Float speed={1.15} rotationIntensity={0.18} floatIntensity={0.42}>
          <PhoneModel />
        </Float>
        <Environment preset="city" />
      </Canvas>
    </div>
  );
}

function PhoneModel() {
  const group = useRef<THREE.Group>(null);
  useFrame((state) => {
    if (!group.current) return;
    group.current.rotation.y = -0.24 + Math.sin(state.clock.elapsedTime * 0.35) * 0.045;
    group.current.rotation.x = 0.09 + Math.sin(state.clock.elapsedTime * 0.28) * 0.028;
  });

  return (
    <group ref={group} rotation={[0.1, -0.25, 0.03]}>
      <RoundedBox args={[2.35, 4.55, 0.22]} radius={0.22} smoothness={8}>
        <meshPhysicalMaterial color="#101219" roughness={0.18} metalness={0.1} transmission={0.18} thickness={0.6} clearcoat={1} />
      </RoundedBox>
      <RoundedBox position={[0, 0, 0.13]} args={[2.12, 4.22, 0.05]} radius={0.18} smoothness={8}>
        <meshPhysicalMaterial color="#FAF8F4" roughness={0.35} clearcoat={0.7} />
      </RoundedBox>
      <AppPanel position={[0, 1.28, 0.18]} scale={[1.64, 0.55, 0.04]} color="#2563FF" />
      <AppPanel position={[-0.48, 0.42, 0.2]} scale={[0.72, 0.72, 0.04]} color="#10B981" />
      <AppPanel position={[0.48, 0.42, 0.205]} scale={[0.72, 0.72, 0.04]} color="#FFFFFF" />
      <AppPanel position={[0, -0.55, 0.2]} scale={[1.64, 0.65, 0.04]} color="#FFFFFF" />
      <AppPanel position={[0, -1.34, 0.205]} scale={[1.64, 0.42, 0.04]} color="#E7EDFF" />
      <mesh position={[-0.55, 1.28, 0.24]}>
        <circleGeometry args={[0.18, 32]} />
        <meshBasicMaterial color="#FFFFFF" />
      </mesh>
    </group>
  );
}

function AppPanel({ position, scale, color }: { position: [number, number, number]; scale: [number, number, number]; color: string }) {
  return (
    <RoundedBox position={position} args={scale} radius={0.08} smoothness={6}>
      <meshPhysicalMaterial color={color} roughness={0.28} clearcoat={0.7} transparent opacity={color === '#FFFFFF' ? 0.82 : 0.94} />
    </RoundedBox>
  );
}
