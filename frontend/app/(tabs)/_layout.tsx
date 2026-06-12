import React from "react";
import { Tabs, Redirect } from "expo-router";
import { Home, Dumbbell, UtensilsCrossed, Moon, User } from "lucide-react-native";
import { COLORS } from "@/src/constants/theme";
import { useAuth } from "@/src/context/AuthContext";
import { Platform, View, ActivityIndicator } from "react-native";

export default function TabsLayout() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <View style={{ flex: 1, alignItems: "center", justifyContent: "center", backgroundColor: COLORS.background }}>
        <ActivityIndicator color={COLORS.primary} />
      </View>
    );
  }
  if (!user) return <Redirect href="/(auth)/login" />;

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: COLORS.nav.active,
        tabBarInactiveTintColor: COLORS.nav.inactive,
        tabBarStyle: {
          backgroundColor: "#FFFFFF",
          borderTopColor: "#E5E7EB",
          borderTopWidth: 1,
          height: Platform.OS === "ios" ? 86 : 64,
          paddingBottom: Platform.OS === "ios" ? 28 : 8,
          paddingTop: 8,
        },
        tabBarLabelStyle: { fontSize: 11, fontWeight: "600" },
      }}
    >
      <Tabs.Screen
        name="home"
        options={{
          title: "Home",
          tabBarIcon: ({ color, size }) => <Home color={color} size={size} strokeWidth={2.5} />,
        }}
      />
      <Tabs.Screen
        name="workout"
        options={{
          title: "Workout",
          tabBarIcon: ({ color, size }) => <Dumbbell color={color} size={size} strokeWidth={2.5} />,
        }}
      />
      <Tabs.Screen
        name="meals"
        options={{
          title: "Meals",
          tabBarIcon: ({ color, size }) => <UtensilsCrossed color={color} size={size} strokeWidth={2.5} />,
        }}
      />
      <Tabs.Screen
        name="sleep"
        options={{
          title: "Sleep",
          tabBarIcon: ({ color, size }) => <Moon color={color} size={size} strokeWidth={2.5} />,
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: "Profile",
          tabBarIcon: ({ color, size }) => <User color={color} size={size} strokeWidth={2.5} />,
        }}
      />
    </Tabs>
  );
}
