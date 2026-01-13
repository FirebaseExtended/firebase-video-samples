import React from "react";
import {
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
} from "@/components/ui/navigation-menu"
import { Outlet } from "react-router";
import { useMatch } from "react-router";

const MenuLink: React.FC<{ href: string, label: string }> = ({ href, label }) => {
  const active = useMatch(href);
  const classes = "group inline-flex h-9 w-max items-center justify-center rounded-md bg-background px-4 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground focus:outline-none disabled:pointer-events-none disabled:opacity-50 data-[active]:bg-accent/50 data-[state=open]:bg-accent/50"

  return (
    <NavigationMenuLink asChild active={active !== null} className={classes}>
      <a href={href}>{label}</a>
    </NavigationMenuLink>
  )
}

const Layout: React.FC = () => {

  return (
    <div className="min-h-screen bg-background">
      <header className="flex items-center justify-between p-4 border-b">
        <h1 className="text-xl font-bold">Friendly Meals</h1>
        <NavigationMenu>
          <NavigationMenuList>
            <NavigationMenuItem>
              <MenuLink href="/generate" label="Generate" />
            </NavigationMenuItem>
            <NavigationMenuItem>
              <MenuLink href="/chat" label="Chat" />
            </NavigationMenuItem>
            <NavigationMenuItem>
              <MenuLink href="/image" label="Scan" />
            </NavigationMenuItem>
            <NavigationMenuItem>
              <MenuLink href="/recipes" label="Recipes" />
            </NavigationMenuItem>
          </NavigationMenuList>
        </NavigationMenu>
      </header>
      <main className="container mx-auto p-4">
        <Outlet />
      </main>
    </div>
  );
};

export default Layout;