import React, { createContext, useContext, useEffect, useState } from "react";
import {
  onAuthStateChanged,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  sendPasswordResetEmail,
  signOut,
  updateProfile,
  User,
} from "firebase/auth";
import { ref, set, get } from "firebase/database";
import { auth, db } from "@/src/lib/firebase";
import { seedUserIfEmpty } from "@/src/services/seed";
import { flushPending } from "@/src/services/db";
import type { UserProfile } from "@/src/types/models";

type AuthCtx = {
  user: User | null;
  profile: UserProfile | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  register: (
    name: string,
    email: string,
    password: string,
    extra?: Partial<UserProfile>,
  ) => Promise<void>;
  resetPassword: (email: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshProfile: () => Promise<void>;
};

const Ctx = createContext<AuthCtx | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);

  const loadProfile = async (u: User) => {
    try {
      const snap = await get(ref(db, `finnness/users/${u.uid}/profile`));
      if (snap.exists()) {
        setProfile(snap.val() as UserProfile);
      } else {
        const fallback: UserProfile = {
          uid: u.uid,
          email: u.email ?? "",
          name: u.displayName ?? (u.email ? u.email.split("@")[0] : "User"),
        };
        setProfile(fallback);
      }
    } catch (e) {
      console.warn("loadProfile", e);
    }
  };

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, async (u) => {
      setUser(u);
      if (u) {
        await loadProfile(u);
        seedUserIfEmpty(u.uid).catch(() => {});
        flushPending().catch(() => {});
      } else {
        setProfile(null);
      }
      setLoading(false);
    });
    return unsub;
  }, []);

  const value: AuthCtx = {
    user,
    profile,
    loading,
    signIn: async (email, password) => {
      await signInWithEmailAndPassword(auth, email.trim(), password);
    },
    register: async (name, email, password) => {
      const cred = await createUserWithEmailAndPassword(auth, email.trim(), password);
      await updateProfile(cred.user, { displayName: name });
      const prof: UserProfile = {
        uid: cred.user.uid,
        name,
        email: email.trim(),
        gender: "Female",
        dob: "Jan 15, 1995",
        height: 165,
        weight: 58,
      };
      await set(ref(db, `finnness/users/${cred.user.uid}/profile`), prof);
      await seedUserIfEmpty(cred.user.uid);
    },
    resetPassword: async (email) => {
      await sendPasswordResetEmail(auth, email.trim());
    },
    logout: async () => {
      await signOut(auth);
    },
    refreshProfile: async () => {
      if (user) await loadProfile(user);
    },
  };

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useAuth() {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error("useAuth must be used inside AuthProvider");
  return ctx;
}
