import { Layout } from "@/components/layout/Layout";
import { HeroSection } from "@/components/home/HeroSection";
import { MetricsStrip } from "@/components/home/MetricsStrip";
import { PackageEcosystem } from "@/components/home/PackageEcosystem";
import { DependencyFlow } from "@/components/home/DependencyFlow";
import { InstallSection } from "@/components/home/InstallSection";
import { WhyBeamSection } from "@/components/home/WhyBeamSection";
import { QuickStartCode } from "@/components/home/QuickStartCode";
import { CTASection } from "@/components/home/CTASection";

const Index = () => {
  return (
    <Layout>
      <div className="container">
        <HeroSection />
        <MetricsStrip />
        <PackageEcosystem />
        <DependencyFlow />
        <InstallSection />
        <WhyBeamSection />
        <QuickStartCode />
        <CTASection />
      </div>
    </Layout>
  );
};

export default Index;
