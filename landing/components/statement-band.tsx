import { motion } from 'framer-motion';

const words = ['Plan', 'Log', 'Track', 'Recover', 'Repeat', 'Progress', 'Consistency'];

export function StatementBand() {
  const group = [...words, ...words];
  return (
    <section className="statement-band" aria-label="Atlas philosophy">
      <div className="mx-auto max-w-[1180px] px-5 py-14 text-center sm:py-16">
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10% 0px' }}
          transition={{ duration: 0.9, ease: [0.22, 1, 0.36, 1] }}
          className="mx-auto max-w-3xl text-[clamp(24px,4vw,44px)] font-black leading-[1.06] tracking-normal"
        >
          Atlas is the discipline layer between you, the gym,
          <br className="hidden md:block" /> and the record you are building.
        </motion.p>
      </div>
      <div className="marquee" aria-hidden="true">
        <div className="marquee-track">
          {[0, 1].map((half) => (
            <div className="marquee-group" key={half}>
              {group.map((word, index) => (
                <span key={`${half}-${index}`}>
                  {word}
                  <i style={{ marginLeft: 52, verticalAlign: 'middle' }} />
                </span>
              ))}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}