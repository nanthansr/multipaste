import React from 'react';
import Nav from './Nav';
import Hero from './Hero';
import ShowcaseDemo from './ShowcaseDemo';
import HowItWorks from './HowItWorks';
import Features from './Features';
import Pricing from './Pricing';
import FounderNote from './FounderNote';
import DownloadCTA from './DownloadCTA';
import FeedbackForm from './FeedbackForm';
import Footer from './Footer';

export default function LandingPage() {
  return (
    <div className="min-h-screen selection:bg-blue-500/30">
      <Nav />
      <Hero />
      <ShowcaseDemo />
      <HowItWorks />
      <Features />
      <Pricing />
      <FounderNote />
      <DownloadCTA />
      <FeedbackForm />
      <Footer />
    </div>
  );
}
