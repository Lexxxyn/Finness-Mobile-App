import React, { useEffect } from "react";
import { View, Text, StyleSheet, ActivityIndicator } from "react-native";
import { LinearGradient } from "expo-linear-gradient";
import { Heart } from "lucide-react-native";
import { Redirect } from "expo-router";
import { useAuth } from "@/src/context/AuthContext";
import { WaveShape } from "@/src/components/WaveShape";

export default function Splash() {
  const { user, loading } = useAuth();
  const [showRedirect, setShowRedirect] = React.useState(false);

  useEffect(() => {
    const t = setTimeout(() => setShowRedirect(true), 1600);
    return () => clearTimeout(t);
  }, []);

  if (showRedirect && !loading) {
    return <Redirect href={user ? "/(tabs)/home" : "/(auth)/login"} />;
  }

  return (
    <LinearGradient
      colors={["#42C8F5", "#7BDDFB", "#EEF3F8"]}
      style={styles.container}
      testID="splash-screen"
      // @ts-ignore
      data-testid="splash-screen"
    >
      <View style={styles.center}>
        <View style={styles.circle}>
          <Heart color="#FFFFFF" size={56} strokeWidth={2.5} fill="#FFFFFF55" />
        </View>
        <Text style={styles.brand}>FINNNESS</Text>
        <Text style={styles.tagline}>YOUR WELLNESS JOURNEY</Text>
        {loading ? (
          <ActivityIndicator color="#FFFFFF" style={{ marginTop: 24 }} />
        ) : null}
      </View>
      <View style={styles.wave} pointerEvents="none">
        <WaveShape />
      </View>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: "center", justifyContent: "center" },
  center: { alignItems: "center", paddingHorizontal: 32 },
  circle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: "rgba(255,255,255,0.22)",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 28,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.45)",
  },
  brand: {
    fontSize: 48,
    color: "#FFFFFF",
    fontWeight: "900",
    letterSpacing: -1.2,
  },
  tagline: {
    color: "#FFFFFFEE",
    marginTop: 8,
    fontSize: 12,
    fontWeight: "700",
    letterSpacing: 3.5,
  },
  wave: {
    position: "absolute",
    bottom: 0,
    left: 0,
    right: 0,
    height: 120,
  },
});
