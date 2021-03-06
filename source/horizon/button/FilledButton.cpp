#include "Aether/horizon/button/FilledButton.hpp"

// Corner radius of rectangle
#define CORNER_RAD 8

namespace Aether {
    FilledButton::FilledButton(int x, int y, int w, int h, std::string t, unsigned int s, std::function<void()> f) : Element(x, y, w, h) {
        this->rect = new Rectangle(this->x(), this->y(), this->w(), this->h(), CORNER_RAD);
        this->text = new Text(this->x() + this->w()/2, this->y() + this->h()/2, "", s);
        this->setString(t);
        this->text->setScroll(true);
        this->addElement(this->rect);
        this->addElement(this->text);
        this->setCallback(f);
    }

    Colour FilledButton::getFillColour() {
        return this->rect->getColour();
    }

    void FilledButton::setFillColour(Colour c) {
        this->rect->setColour(c);
    }

    Colour FilledButton::getTextColour() {
        return this->text->getColour();
    }

    void FilledButton::setTextColour(Colour c) {
        this->text->setColour(c);
    }

    std::string FilledButton::getString() {
        return this->text->string();
    }

    void FilledButton::setString(std::string s) {
        this->text->setString(s);
        this->text->setXY(this->rect->x() + (this->rect->w() - this->text->w())/2, this->rect->y() + (this->rect->h() - this->text->h())/2);
        if (this->text->texW() > this->w()) {
            this->text->setW(this->w());
        }
    }

    void FilledButton::setW(int w) {
        Element::setW(w);
        this->rect->setRectSize(this->w(), this->h());
        this->text->setX(this->x() + this->w()/2 - this->text->w()/2);
    }

    void FilledButton::setH(int h) {
        Element::setH(h);
        this->rect->setRectSize(this->w(), this->h());
        this->text->setY(this->y() + this->h()/2 - this->text->h()/2);
    }

    SDL_Texture * FilledButton::renderHighlightBG() {
        return SDLHelper::renderFilledRoundRect(this->w(), this->h(), this->rect->cornerRadius() + 5);
    }

    SDL_Texture * FilledButton::renderHighlight() {
        return SDLHelper::renderRoundRect(this->w() + 2*this->hiSize + 4, this->h() + 2*this->hiSize + 4, this->rect->cornerRadius() + 5, this->hiSize);
    }

    SDL_Texture * FilledButton::renderSelection() {
        // There is no selected texture
        return nullptr;
    }
};