import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Index from "./pages/Index";
import Ecosystem from "./pages/Ecosystem";
import GettingStarted from "./pages/GettingStarted";
import Examples from "./pages/Examples";
import Benchmarks from "./pages/Benchmarks";
import Partners from "./pages/Partners";
import NotFound from "./pages/NotFound";

// Docs pages
import DocsIndex from "./pages/docs/DocsIndex";
import DocsInstallation from "./pages/docs/DocsInstallation";
import DocsQuickstart from "./pages/docs/DocsQuickstart";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <Sonner />
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Index />} />
          <Route path="/ecosystem" element={<Ecosystem />} />
          <Route path="/getting-started" element={<GettingStarted />} />
          <Route path="/examples" element={<Examples />} />
          <Route path="/benchmarks" element={<Benchmarks />} />
          <Route path="/partners" element={<Partners />} />
          
          {/* Documentation */}
          <Route path="/docs" element={<DocsIndex />} />
          <Route path="/docs/installation" element={<DocsInstallation />} />
          <Route path="/docs/quickstart" element={<DocsQuickstart />} />
          
          <Route path="*" element={<NotFound />} />
        </Routes>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;
