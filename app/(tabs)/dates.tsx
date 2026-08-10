import { Screen } from '../../src/components/Screen';
import { StateView } from '../../src/components/StateView';

export default function Dates() {
  return (
    <Screen title="Rendez-vous">
      <StateView
        variant="empty"
        title="Aucun rendez-vous"
        message="L’adresse d’un établissement se révèle à moins de 25 m du point de rendez-vous."
      />
    </Screen>
  );
}
