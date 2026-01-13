import { Link, useLocation } from "react-router-dom";
import { useState, useEffect } from "react";
import { Menu, X, Sun, Moon } from "lucide-react";
import { Button } from "@/components/ui/button";

const navLinks = [
  { href: "/ecosystem", label: "/ecosystem" },
  { href: "/partners", label: "/partners" },
  { href: "/examples", label: "/examples" },
  { href: "/benchmarks", label: "/benchmarks" },
  { href: "/docs", label: "/docs" },
];

export function Header() {
  const location = useLocation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [isDark, setIsDark] = useState(true);
  const [isScrolled, setIsScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };
    
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  useEffect(() => {
    // Check initial preference
    const savedTheme = localStorage.getItem("theme");
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    
    if (savedTheme === "light" || (!savedTheme && !prefersDark)) {
      setIsDark(false);
      document.documentElement.classList.add("light");
    }
  }, []);

  const toggleTheme = () => {
    setIsDark(!isDark);
    if (isDark) {
      document.documentElement.classList.add("light");
      localStorage.setItem("theme", "light");
    } else {
      document.documentElement.classList.remove("light");
      localStorage.setItem("theme", "dark");
    }
  };

  return (
    <>
      {/* Theme Toggle - Fixed position */}
      <div className="fixed top-4 right-4 z-[100] flex gap-1 bg-surface border border-border rounded p-1">
        <button
          onClick={() => { if (!isDark) toggleTheme(); }}
          className={`px-3 py-1.5 rounded text-[10px] font-semibold transition-colors ${
            isDark 
              ? "bg-primary text-primary-foreground" 
              : "text-muted-foreground hover:text-foreground"
          }`}
        >
          DARK
        </button>
        <button
          onClick={() => { if (isDark) toggleTheme(); }}
          className={`px-3 py-1.5 rounded text-[10px] font-semibold transition-colors ${
            !isDark 
              ? "bg-primary text-primary-foreground" 
              : "text-muted-foreground hover:text-foreground"
          }`}
        >
          LIGHT
        </button>
      </div>

      <header className={`sticky top-0 z-50 bg-background/80 backdrop-blur-md transition-all duration-300 ${isScrolled ? 'pt-2 pb-2' : 'pt-6 pb-12'}`}>
        <div className="container">
          <nav className={`nav-surface flex justify-between items-center px-6 transition-all duration-300 ${isScrolled ? 'py-3' : 'py-5'}`}>
            {/* Logo */}
            <Link to="/" className="flex items-center gap-2.5">
              <div className={`rounded flex items-center justify-center font-bold text-primary-foreground bg-gradient-to-br from-primary to-accent-yellow transition-all duration-300 ${isScrolled ? 'w-6 h-6 text-xs' : 'w-7 h-7 text-sm'}`}>
                J
              </div>
              <span className={`font-bold tracking-wide transition-all duration-300 ${isScrolled ? 'text-sm' : 'text-base'}`}>JIDO</span>
              <span className="text-muted-foreground text-[11px] ml-1">v0.1.0</span>
            </Link>

            {/* Desktop Navigation */}
            <div className="hidden md:flex items-center gap-7">
              {navLinks.map((link) => (
                <Link
                  key={link.href}
                  to={link.href}
                  className={`text-xs transition-colors ${
                    location.pathname === link.href
                      ? "text-primary font-semibold"
                      : "text-secondary-foreground hover:text-foreground"
                  }`}
                >
                  {link.label}
                </Link>
              ))}
              <a
                href="mailto:support@agentjido.com?subject=Premium%20Support%20Inquiry"
                className="text-xs font-medium bg-gradient-to-r from-accent-yellow to-accent-red bg-clip-text text-transparent hover:opacity-80 transition-opacity"
              >
                Premium Support
              </a>
            </div>

            {/* CTA Button */}
            <div className="hidden md:block">
              <Button asChild className="bg-primary text-primary-foreground hover:bg-primary/90 text-xs font-bold px-4 py-2.5">
                <Link to="/getting-started">$ GET STARTED</Link>
              </Button>
            </div>

            {/* Mobile menu button */}
            <Button
              variant="ghost"
              size="icon"
              className="md:hidden"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            >
              {mobileMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </Button>
          </nav>

          {/* Mobile Navigation */}
          {mobileMenuOpen && (
            <div className="md:hidden mt-2 nav-surface p-4">
              <nav className="flex flex-col gap-2">
                {navLinks.map((link) => (
                  <Link
                    key={link.href}
                    to={link.href}
                    onClick={() => setMobileMenuOpen(false)}
                    className={`px-4 py-3 text-xs rounded transition-colors ${
                      location.pathname === link.href
                        ? "text-primary bg-primary/10 font-semibold"
                        : "text-secondary-foreground hover:text-foreground hover:bg-muted"
                    }`}
                  >
                    {link.label}
                  </Link>
                ))}
                <a
                  href="mailto:support@agentjido.com?subject=Premium%20Support%20Inquiry"
                  onClick={() => setMobileMenuOpen(false)}
                  className="px-4 py-3 text-xs rounded bg-gradient-to-r from-accent-yellow to-accent-red bg-clip-text text-transparent font-medium"
                >
                  Premium Support
                </a>
                <Button asChild className="mt-4 bg-primary text-primary-foreground text-xs font-bold">
                  <Link to="/getting-started" onClick={() => setMobileMenuOpen(false)}>
                    $ GET STARTED
                  </Link>
                </Button>
              </nav>
            </div>
          )}
        </div>
      </header>
    </>
  );
}
